import { http } from '@/services/http.service';

class ExpenseAPI {
  async fetchExpenses(page = 1, search = '') {
    const res = await http.get(`/api/v1//my_finance_app/expenses?page=${page}&search=${search}`);
    return res.data;
  }
  async fetchTrashesExpenses(page = 1, search = '') {
    const res = await http.get(`/api/v1/my_finance_app/expenses/trashes?page=${page}&search=${search}`);
    return res.data;
  }
  async fetchExpense(id: number) {
    const res = await http.get(`/api/v1//my_finance_app/expenses/${id}`);
    return res.data;
  }
  async updateExpense(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/my_finance_app/expenses/${id}`, data, { headers });
    return res.data;
  }
  async createExpense(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post('/api/v1/my_finance_app/expenses/', data, { headers });
    return res.data;
  }
  async deleteExpense(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/my_finance_app/expenses/${id}`);
    return res.data;
  }
  async expenseDeletePermanently(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/my_finance_app/expenses/${id}/destroy_permanently`);
    return res.data;
  }
  async expenseRestore(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/my_finance_app/expenses/${id}/restore`);
    return res.data;
  }
  async fetchTags(search = '') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/tags?search=${search}`, { headers });
    return res.data;
  }
  async fetchPieChartDataByTag() {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/expenses/pie_chart_data_by_tag`, { headers });
    return res.data;
  }
  async fetchTotalAmountYears(chartType: string) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/expenses/total_expenses_last_years_or_months?chart_type=${chartType}`, { headers });
    return res.data;
  }
  async fetchPieChartDataBySubcategories(tag_id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/expenses/pie_chart_data_by_subcategories?tag_id=${tag_id}`, { headers });
    return res.data;
  }
  async createTag(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/my_finance_app/expenses/tags`, data, { headers });
    return res.data;
  }
}

const instance = new ExpenseAPI();

export default instance;
