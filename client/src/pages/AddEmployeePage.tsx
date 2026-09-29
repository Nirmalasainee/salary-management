import { useEffect, useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { Box, Typography, Paper, TextField, MenuItem, Button, Alert, Stack } from "@mui/material";
import { fetchReferenceData, createEmployee, createSalaryRecord, type ReferenceData } from "../api";

export default function AddEmployeePage() {
  const navigate = useNavigate();
  const [referenceData, setReferenceData] = useState<ReferenceData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const [employeeNumber, setEmployeeNumber] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [countryId, setCountryId] = useState("");
  const [departmentId, setDepartmentId] = useState("");
  const [jobLevelId, setJobLevelId] = useState("");
  const [hireDate, setHireDate] = useState("");
  const [amount, setAmount] = useState<number | "">("");
  const [currencyCode, setCurrencyCode] = useState("");

  useEffect(() => {
    fetchReferenceData().then(setReferenceData).catch(() => {});
  }, []);

  const handleCountryChange = (value: string) => {
    setCountryId(value);
    const country = referenceData?.countries.find((c) => String(c.id) === value);
    if (country) setCurrencyCode(country.currency_code);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const employee = await createEmployee({
        employee_number: employeeNumber,
        first_name: firstName,
        last_name: lastName,
        email,
        country_id: Number(countryId),
        department_id: Number(departmentId),
        job_level_id: Number(jobLevelId),
        hire_date: hireDate,
        status: "active",
      });

      await createSalaryRecord(employee.id, {
        amount: Number(amount),
        currency_code: currencyCode,
        effective_start_date: hireDate,
        change_reason: "hire",
      });

      navigate(`/employees/${employee.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>Add Employee</Typography>
      <Paper sx={{ p: 3, maxWidth: 680, mx: "auto" }}>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        <Box
          component="form"
          onSubmit={handleSubmit}
          sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "1fr 1fr" }, gap: 2 }}
        >
          <TextField label="Employee number" required value={employeeNumber} onChange={(e) => setEmployeeNumber(e.target.value)} />
          <TextField label="First name" required value={firstName} onChange={(e) => setFirstName(e.target.value)} />

          <TextField label="Last name" required value={lastName} onChange={(e) => setLastName(e.target.value)} />
          <TextField label="Email" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} />

          <TextField select label="Country" required value={countryId} onChange={(e) => handleCountryChange(e.target.value)}>
            {referenceData?.countries.map((c) => <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>)}
          </TextField>
          <TextField select label="Department" required value={departmentId} onChange={(e) => setDepartmentId(e.target.value)}>
            {referenceData?.departments.map((d) => <MenuItem key={d.id} value={d.id}>{d.name}</MenuItem>)}
          </TextField>

          <TextField select label="Level" required value={jobLevelId} onChange={(e) => setJobLevelId(e.target.value)}>
            {referenceData?.job_levels.map((l) => <MenuItem key={l.id} value={l.id}>{l.name}</MenuItem>)}
          </TextField>
          <TextField
            label="Hire date" type="date" required
            value={hireDate}
            onChange={(e) => setHireDate(e.target.value)}
            slotProps={{ inputLabel: { shrink: true } }}
          />

          <TextField
            label="Starting salary" type="number" required
            value={amount}
            onChange={(e) => setAmount(e.target.value === "" ? "" : Number(e.target.value))}
          />
          <TextField
            label="Currency code" required
            value={currencyCode}
            onChange={(e) => setCurrencyCode(e.target.value.toUpperCase())}
            slotProps={{ htmlInput: { maxLength: 3 } }}
          />

          <Stack direction="row" spacing={2} sx={{ gridColumn: "1 / -1" }}>
            <Button type="submit" variant="contained" disabled={submitting}>
              {submitting ? "Creating..." : "Create Employee"}
            </Button>
            <Button variant="outlined" onClick={() => navigate("/employees")} disabled={submitting}>
              Cancel
            </Button>
          </Stack>
        </Box>
      </Paper>
    </Box>
  );
}
