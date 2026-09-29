import { useEffect, useState } from "react";
import { Box, Typography, Paper } from "@mui/material";
import { BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer } from "recharts";
import {
  fetchSummary, fetchReportByDepartment, fetchReportByCountry, fetchReportByJobLevel,
  type Summary, type ReportGroup,
} from "../api";

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <Paper sx={{ p: 2, flex: "1 1 200px" }}>
      <Typography variant="body2" color="text.secondary">{label}</Typography>
      <Typography variant="h5">{value}</Typography>
    </Paper>
  );
}

function ReportChart({ title, data }: { title: string; data: ReportGroup[] }) {
  return (
    <Paper sx={{ p: 2, flex: "1 1 420px", height: 360 }}>
      <Typography variant="h6" gutterBottom>{title}</Typography>
      <ResponsiveContainer width="100%" height="85%">
        <BarChart data={data} margin={{ top: 10, right: 20, left: 0, bottom: 40 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="label" angle={-30} textAnchor="end" interval={0} height={60} />
          <YAxis />
          <Tooltip formatter={(value: number) => [value.toLocaleString(), "Avg USD"]} />
          <Bar dataKey="average_salary_usd" fill="#1976d2" />
        </BarChart>
      </ResponsiveContainer>
    </Paper>
  );
}

const usd = (n: number) => `$${n.toLocaleString(undefined, { maximumFractionDigits: 0 })}`;

export default function DashboardPage() {
  const [summary, setSummary] = useState<Summary | null>(null);
  const [byDepartment, setByDepartment] = useState<ReportGroup[]>([]);
  const [byCountry, setByCountry] = useState<ReportGroup[]>([]);
  const [byJobLevel, setByJobLevel] = useState<ReportGroup[]>([]);

  useEffect(() => {
    fetchSummary().then(setSummary).catch(() => {});
    fetchReportByDepartment().then(setByDepartment).catch(() => {});
    fetchReportByCountry().then(setByCountry).catch(() => {});
    fetchReportByJobLevel().then(setByJobLevel).catch(() => {});
  }, []);

  return (
    <Box>
      <Typography variant="h5" gutterBottom>Dashboard</Typography>

      <Box sx={{ display: "flex", gap: 2, flexWrap: "wrap", mb: 3 }}>
        <StatCard label="Headcount" value={summary ? summary.headcount.toLocaleString() : "…"} />
        <StatCard label="Total Payroll (USD)" value={summary ? usd(summary.total_payroll_usd) : "…"} />
        <StatCard label="Average Salary (USD)" value={summary ? usd(summary.average_salary_usd) : "…"} />
        <StatCard label="Median Salary (USD)" value={summary ? usd(summary.median_salary_usd) : "…"} />
      </Box>

      <Box sx={{ display: "flex", gap: 3, flexWrap: "wrap" }}>
        <ReportChart title="Average Salary by Department" data={byDepartment} />
        <ReportChart title="Average Salary by Country" data={byCountry} />
        <ReportChart title="Average Salary by Level" data={byJobLevel} />
      </Box>
    </Box>
  );
}
