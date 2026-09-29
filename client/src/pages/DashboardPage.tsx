import { useEffect, useState } from "react";
import { Typography } from "@mui/material";
import { fetchSummary, type Summary } from "../api";

export default function DashboardPage() {
  const [summary, setSummary] = useState<Summary | null>(null);

  useEffect(() => {
    fetchSummary().then(setSummary).catch(() => {});
  }, []);

  return (
    <div>
      <Typography variant="h5" gutterBottom>Dashboard</Typography>
      {summary && (
        <>
          <Typography>Headcount: {summary.headcount}</Typography>
          <Typography>Total payroll (USD): {summary.total_payroll_usd.toLocaleString()}</Typography>
        </>
      )}
    </div>
  );
}
