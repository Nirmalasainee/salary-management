import { Routes, Route, Navigate } from "react-router-dom";
import Layout from "./components/Layout";
import EmployeeListPage from "./pages/EmployeeListPage";
import DashboardPage from "./pages/DashboardPage";
import EmployeeDetailPage from "./pages/EmployeeDetailPage";


function App() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route path="/" element={<Navigate to="/employees" replace />} />
        <Route path="/employees" element={<EmployeeListPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/employees/:id" element={<EmployeeDetailPage />} />
      </Route>
    </Routes>
  );
}

export default App;
