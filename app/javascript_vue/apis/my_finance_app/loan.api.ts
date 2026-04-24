import { http } from '@/services/http.service';

class LoanAPI {
  async fetchLoans(page = 1, search = '', loan_type = 'all') {
    const res = await http.get(`/api/v1//my_finance_app/loans?page=${page}&search=${search}&loan_type=${loan_type}`);
    return res.data;
  }
  async fetchPaidLoans(page = 1, search = '', loan_type = 'all') {
    const res = await http.get(`/api/v1//my_finance_app/loans/paid?page=${page}&search=${search}&loan_type=${loan_type}`);
    return res.data;
  }
  async fetchTrashesLoans(page = 1, search = '', loan_type = 'all') {
    const res = await http.get(`/api/v1/my_finance_app/loans/trashes?page=${page}&search=${search}&loan_type=${loan_type}`);
    return res.data;
  }
  async fetchLoan(id: number) {
    const res = await http.get(`/api/v1//my_finance_app/loans/${id}`);
    return res.data;
  }
  async updateLoan(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/my_finance_app/loans/${id}`, data, { headers });
    return res.data;
  }
  async createLoan(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post('/api/v1/my_finance_app/loans/', data, { headers });
    return res.data;
  }
  async deleteLoan(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/my_finance_app/loans/${id}`);
    return res.data;
  }
  async loanDeletePermanently(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/my_finance_app/loans/${id}/destroy_permanently`);
    return res.data;
  }
  async loanRestore(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/my_finance_app/loans/${id}/restore`);
    return res.data;
  }
  async fetchTags(search = '') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/loans/tags?search=${search}`, { headers });
    return res.data;
  }
  async fetchPieChartDataByTag(loan_type = 'given', status = 'unpaid') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/loans/pie_chart_data_by_cantact_name?loan_type=${loan_type}&status=${status}`, { headers });
    return res.data;
  }
  async fetchTotalAmountYears(chartType: string) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/loans/total_loans_last_years_or_months?chart_type=${chartType}`, { headers });
    return res.data;
  }
  async createTag(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/my_finance_app/loans/create_tag`, data, { headers });
    return res.data;
  }
  async createLoanPayment(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/my_finance_app/loans/${id}/create_payment`, data, { headers });
    return res.data;
  }
}

const instance = new LoanAPI();

export default instance;
