import { defineStore } from 'pinia';
import LoanAPI from '@/apis/my_finance_app/loan.api';

export const useLoanStore = defineStore({
  id: 'loan-store',
  state: () => ({
    loan: {},
    loans: [],
    paidLoans: [],
    trashesLoans: [],
    tags: [],
    search: '',
    paidLoanSearch: '',
    loading: true,
    pagination: {},
    trashesLoansPagination: {},
    paidLoansPagination: {},
    page: 1,
    paidLoanPage: 1,
    loanType: 'all',
    paidLoanType: 'all',
    trashedLoanType: 'all'
  }),
  getters: {},
  actions: {
    async fetchLoans() {
      this.loading = true;
      const res = await LoanAPI.fetchLoans(this.page, this.search, this.loanType);
      this.loans = res?.loans;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchPaidLoans() {
      this.loading = true;
      const res = await LoanAPI.fetchPaidLoans(this.paidLoanPage, this.paidLoanSearch, this.paidLoanType);
      this.paidLoans = res?.loans;
      this.paidLoansPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchTrashesLoans() {
      this.loading = true;
      const res = await LoanAPI.fetchTrashesLoans(1, this.search, this.trashedLoanType);
      this.trashesLoans = res?.loans;
      this.trashesLoansPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchLoan(id: number) {
      const res = await LoanAPI.fetchLoan(id);
      this.loan = res.loan;
      this.loading = false;
      return res.loan
    },
    async updateLoan(data: {}) {
      const res = await LoanAPI.updateLoan(data.loan.id, data);
      this.loans = this.loans.map((mapLoan) => {
        if (res.loan.id === mapLoan.id) {
          return res.loan
        }
        return mapLoan
      })

      this.paidLoans = this.paidLoans.map((mapLoan) => {
        if (res.loan.id === mapLoan.id) {
          return res.loan
        }
        return mapLoan
      })
    },
    async createLoan(data: {}) {
      const res = await LoanAPI.createLoan(data);
      this.loan = res.loan;
      return res.loan
    },
    async deleteLoan(id: number) {
      await LoanAPI.deleteLoan(id);
      await this.fetchTrashesLoans()
      await this.fetchPaidLoans()
      await this.fetchLoans()
    },
    async loanRestore(id: number) {
      await LoanAPI.loanRestore(id);
      await this.fetchTrashesLoans()
    },
    async loanDeletePermanently(id: number) {
      await LoanAPI.loanDeletePermanently(id);
      await this.fetchTrashesLoans()
    },
    async fetchTags(search = '') {
      const res = await LoanAPI.fetchTags(search);
      this.tags = res.tags
      return res.tags
    },
    async createTag(text: string) {
      const res = await LoanAPI.createTag({ text: text });
      this.tags.unshift(res.tag)
      return res.tag
    },
    async fetchPieChartDataByTag(loan_type = 'given', status = 'unpaid') {
      const res = await LoanAPI.fetchPieChartDataByTag(loan_type, status);
      return res
    },
    async fetchTotalAmountYears(chartType: string) {
      const res = await LoanAPI.fetchTotalAmountYears(chartType);
      return res
    },
    async createLoanPayment(id: number, data: {}) {
      const res = await LoanAPI.createLoanPayment(id, data);
      await this.fetchPaidLoans()
      await this.fetchLoans()
      return res
    },
    async resetStates() {
      this.loan = {};
      this.loans = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    }
  }
})