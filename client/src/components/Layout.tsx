import { AppBar, Toolbar, Typography, Button, Container } from "@mui/material";
import { Link, Outlet } from "react-router-dom";

export default function Layout() {
  return (
    <>
      <AppBar position="static" color="default" elevation={1}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1 }}>Salary Management</Typography>
          <Button component={Link} to="/employees">Employees</Button>
          <Button component={Link} to="/dashboard">Dashboard</Button>
        </Toolbar>
      </AppBar>
      <Container sx={{ mt: 3 }}>
        <Outlet />
      </Container>
    </>
  );
}
