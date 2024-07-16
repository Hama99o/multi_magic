import { http } from '@/services/http.service';

class LoanPaymentAPI {
  async deleteLoanPayment(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/my_finance_app/loan_payments/${id}`);
    return res.data;
  }
}

const instance = new LoanPaymentAPI();

export default instance;
