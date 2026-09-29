import { useEffect, useState, type FormEvent } from "react";
import { useParams, Link } from "react-router-dom";
import {
  Box, Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody,
  TextField, MenuItem, Button, Alert, Stack,
} from "@mui/material";
import {
  fetchEmployee, createSalaryRecord,
  type EmployeeDetail, type SalaryChangePayload,
} from "../api";

const CHANGE_REASONS = ["hire", "merit", "promotion", "market_adjustment"];

export default function EmployeeDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [employee, setEmployee] = useState<EmployeeDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [formError, setFormError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [form, setForm] = useState<SalaryChangePayload>({
    amount: 0,
    currency_code: "",
    effective_start_date: "",
    change_reason: "merit",
  });

  const load = () => {
    if (!id) return;
    setLoading(true);
    fetchEmployee(id)
      .then((data) => {
        setEmployee(data);
        setForm((f) => ({ ...f, currency_code: data.current_salary?.currency_code ?? f.currency_code }));
      })
      .finally(() => setLoading(false));
  };

  useEffect(load, [id]);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!id) return;
    setFormError(null);
    setSubmitting(true);
    try {
      await createSalaryRecord(id, form);
      load();
      setForm((f) => ({ ...f, amount: 0, effective_start_date: "" }));
    } catch (err) {
      setFormError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return <Typography>Loading...</Typography>;
  if (!employee) return <Typography>Employee not found.</Typography>;

  return (
    <Box>
      <Button component={Link} to="/employees" sx={{ mb: 2 }}>&larr; Back to Employees</Button>

      <Typography variant="h5" gutterBottom>
        {employee.first_name} {employee.last_name} ({employee.employee_number})
      </Typography>

      <Box sx={{ display: "flex", gap: 3, flexWrap: "wrap" }}>
        <Paper sx={{ p: 2, flex: "1 1 320px" }}>
          <Typography variant="h6" gutterBottom>Profile</Typography>
          <Typography>Email: {employee.email}</Typography>
          <Typography>Country: {employee.country}</Typography>
          <Typography>Department: {employee.department}</Typography>
          <Typography>Level: {employee.job_level}</Typography>
          <Typography>Status: {employee.status}</Typography>
          <Typography>Hire date: {employee.hire_date}</Typography>
          <Typography sx={{ mt: 2 }}>
            Current salary:{" "}
            {employee.current_salary
              ? `${employee.current_salary.amount} ${employee.current_salary.currency_code} (since ${employee.current_salary.effective_start_date})`
              : "None on record"}
          </Typography>
        </Paper>

        <Paper sx={{ p: 2, flex: "1 1 320px" }}>
          <Typography variant="h6" gutterBottom>Record Salary Change</Typography>
          {formError && <Alert severity="error" sx={{ mb: 2 }}>{formError}</Alert>}
          <Stack component="form" spacing={2} onSubmit={handleSubmit}>
            <TextField
              label="New amount"
              type="number"
              required
              value={form.amount || ""}
              onChange={(e) => setForm((f) => ({ ...f, amount: Number(e.target.value) }))}
            />
            <TextField
              label="Currency code"
              required
              value={form.currency_code}
              onChange={(e) => setForm((f) => ({ ...f, currency_code: e.target.value.toUpperCase() }))}
              slotProps={{ htmlInput: { maxLength: 3 } }}
            />
            <TextField
              label="Effective start date"
              type="date"
              required
              value={form.effective_start_date}
              onChange={(e) => setForm((f) => ({ ...f, effective_start_date: e.target.value }))}
              slotProps={{ inputLabel: { shrink: true } }}
            />
            <TextField
              select label="Reason" required
              value={form.change_reason}
              onChange={(e) => setForm((f) => ({ ...f, change_reason: e.target.value }))}
            >
              {CHANGE_REASONS.map((r) => <MenuItem key={r} value={r}>{r}</MenuItem>)}
            </TextField>
            <Button type="submit" variant="contained" disabled={submitting}>
              {submitting ? "Saving..." : "Save Salary Change"}
            </Button>
          </Stack>
        </Paper>
      </Box>

      <Paper sx={{ p: 2, mt: 3 }}>
        <Typography variant="h6" gutterBottom>Salary History</Typography>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Amount</TableCell>
              <TableCell>Currency</TableCell>
              <TableCell>Effective Start</TableCell>
              <TableCell>Effective End</TableCell>
              <TableCell>Reason</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {employee.salary_history.map((s) => (
              <TableRow key={s.id}>
                <TableCell>{s.amount}</TableCell>
                <TableCell>{s.currency_code}</TableCell>
                <TableCell>{s.effective_start_date}</TableCell>
                <TableCell>{s.effective_end_date ?? "Current"}</TableCell>
                <TableCell>{s.change_reason}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Paper>
    </Box>
  );
}
