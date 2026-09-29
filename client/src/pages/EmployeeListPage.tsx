import { useEffect, useState } from "react";
import { Box, TextField, MenuItem, Stack, Typography, Button } from "@mui/material";
import { DataGrid, type GridColDef, type GridPaginationModel } from "@mui/x-data-grid";
import { fetchEmployees, fetchReferenceData, type Employee, type ReferenceData } from "../api";
import { Link, useNavigate } from "react-router-dom";



const columns: GridColDef[] = [
  { field: "employee_number", headerName: "Employee #", width: 120 },
  { field: "first_name", headerName: "First Name", width: 140 },
  { field: "last_name", headerName: "Last Name", width: 140 },
  { field: "email", headerName: "Email", width: 220 },
  { field: "department", headerName: "Department", width: 160 },
  { field: "country", headerName: "Country", width: 140 },
  { field: "job_level", headerName: "Level", width: 120 },
  { field: "status", headerName: "Status", width: 100 },
];

export default function EmployeeListPage() {
  const navigate = useNavigate();
  const [rows, setRows] = useState<Employee[]>([]);
  const [rowCount, setRowCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const [paginationModel, setPaginationModel] = useState<GridPaginationModel>({ page: 0, pageSize: 25 });
  const [search, setSearch] = useState("");
  const [countryId, setCountryId] = useState("");
  const [departmentId, setDepartmentId] = useState("");
  const [jobLevelId, setJobLevelId] = useState("");
  const [referenceData, setReferenceData] = useState<ReferenceData | null>(null);

  useEffect(() => {
    fetchReferenceData().then(setReferenceData).catch(() => {});
  }, []);

  useEffect(() => {
    setLoading(true);
    fetchEmployees({
      page: paginationModel.page + 1,
      per_page: paginationModel.pageSize,
      search,
      country_id: countryId ? Number(countryId) : undefined,
      department_id: departmentId ? Number(departmentId) : undefined,
      job_level_id: jobLevelId ? Number(jobLevelId) : undefined,
    })
      .then((data) => {
        setRows(data.employees);
        setRowCount(data.meta.total_count);
      })
      .finally(() => setLoading(false));
  }, [paginationModel, search, countryId, departmentId, jobLevelId]);

  const resetToFirstPage = () => setPaginationModel((p) => ({ ...p, page: 0 }));

  return (
    <Box>
      <Typography variant="h5" gutterBottom>Employees</Typography>
      <Button component={Link} to="/employees/new" variant="contained" sx={{ mb: 2 }}>
        + Add Employee
      </Button>


      <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
        <TextField
          label="Search name, email, employee #"
          size="small"
          value={search}
          onChange={(e) => { setSearch(e.target.value); resetToFirstPage(); }}
          sx={{ minWidth: 260 }}
        />
        <TextField
          select label="Country" size="small" sx={{ minWidth: 160 }}
          value={countryId}
          onChange={(e) => { setCountryId(e.target.value); resetToFirstPage(); }}
        >
          <MenuItem value="">All</MenuItem>
          {referenceData?.countries.map((c) => <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>)}
        </TextField>
        <TextField
          select label="Department" size="small" sx={{ minWidth: 160 }}
          value={departmentId}
          onChange={(e) => { setDepartmentId(e.target.value); resetToFirstPage(); }}
        >
          <MenuItem value="">All</MenuItem>
          {referenceData?.departments.map((d) => <MenuItem key={d.id} value={d.id}>{d.name}</MenuItem>)}
        </TextField>
        <TextField
          select label="Level" size="small" sx={{ minWidth: 160 }}
          value={jobLevelId}
          onChange={(e) => { setJobLevelId(e.target.value); resetToFirstPage(); }}
        >
          <MenuItem value="">All</MenuItem>
          {referenceData?.job_levels.map((l) => <MenuItem key={l.id} value={l.id}>{l.name}</MenuItem>)}
        </TextField>
      </Stack>

      <Box sx={{ height: 600 }}>
        <DataGrid
          rows={rows}
          columns={columns}
          rowCount={rowCount}
          loading={loading}
          paginationMode="server"
          paginationModel={paginationModel}
          onPaginationModelChange={setPaginationModel}
          pageSizeOptions={[25, 50, 100]}
          onRowClick={(params) => navigate(`/employees/${params.id}`)}
          disableColumnFilter
          disableRowSelectionOnClick
        />
      </Box>
    </Box>
  );
}
