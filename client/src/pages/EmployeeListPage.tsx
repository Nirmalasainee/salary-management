import { useEffect, useState } from "react";
import { Box, TextField, MenuItem, Stack, Typography, Button } from "@mui/material";
import { DataGrid, type GridColDef, type GridPaginationModel } from "@mui/x-data-grid";
import { fetchEmployees, fetchReferenceData, type Employee, type ReferenceData } from "../api";
import { Link, useNavigate } from "react-router-dom";



const columns: GridColDef[] = [
  { field: "employee_number", headerName: "Employee #", width: 120 },
  { field: "first_name", headerName: "First Name", flex: 1, minWidth: 120 },
  { field: "last_name", headerName: "Last Name", flex: 1, minWidth: 120 },
  { field: "email", headerName: "Email", flex: 1.5, minWidth: 200 },
  { field: "department", headerName: "Department", flex: 1, minWidth: 140 },
  { field: "country", headerName: "Country", flex: 1, minWidth: 130 },
  { field: "job_level", headerName: "Level", flex: 1, minWidth: 110 },
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
      <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
        <Typography variant="h5">Employees</Typography>
        <Button component={Link} to="/employees/new" variant="contained">
          + Add Employee
        </Button>
      </Box>

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
