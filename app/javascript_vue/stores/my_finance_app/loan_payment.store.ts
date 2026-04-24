import { defineStore } from 'pinia';
import LoanPaymentAPI from '@/apis/my_finance_app/loan_payment.api';

export const useLoanPaymentStore = defineStore({
  id: 'loan-payment-store',
  state: () => ({
  }),
  getters: {},
  actions: {
    async deleteLoanPayment(id: number) {
      await LoanPaymentAPI.deleteLoanPayment(id);
    }
  }
})