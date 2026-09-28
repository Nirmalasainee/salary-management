import { useEffect, useState } from "react";
import { fetchSummary, type Summary } from "./api";

function App() {
  const [summary, setSummary] = useState<Summary | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchSummary()
      .then(setSummary)
      .catch((err) => setError(err.message));
  }, []);

  if (error) return <p>Error: {error}</p>;
  if (!summary) return <p>Loading...</p>;

  return (
    <div>
      <h1>Salary Management</h1>
      <p>Headcount: {summary.headcount}</p>
      <p>Total payroll (USD): {summary.total_payroll_usd.toLocaleString()}</p>
    </div>
  );
}

export default App;
