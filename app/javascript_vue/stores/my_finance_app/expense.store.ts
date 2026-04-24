import { defineStore } from 'pinia';
import ExpenseAPI from '@/apis/my_finance_app/expense.api';

export const useExpenseStore = defineStore({
  id: 'expense-store',
  state: () => ({
    expense: {},
    expenses: [],
    trashesExpenses: [],
    search: '',
    loading: true,
    pagination: {},
    trashesExpensesPagination: {},
    page: 1,
  }),
  getters: {},
  actions: {
    async fetchExpenses() {
      this.loading = true;
      const res = await ExpenseAPI.fetchExpenses(this.page, this.search);
      this.expenses = res?.expenses;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchTrashesExpenses() {
      this.loading = true;
      const res = await ExpenseAPI.fetchTrashesExpenses(1, this.search);
      this.trashesExpenses = res?.expenses;
      this.trashesExpensesPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchExpense(id: number) {
      const res = await ExpenseAPI.fetchExpense(id);
      this.expense = res.expense;
      this.loading = false;
      return res.expense
    },
    async updateExpense(data: {}) {
      const res = await ExpenseAPI.updateExpense(data.expense.id, data);

      this.expenses = this.expenses.map((mapExpense) => {
        if (res.expense.id === mapExpense.id) {
          return res.expense
        }
        return mapExpense
      })
    },
    async createExpense(data: {}) {
      const res = await ExpenseAPI.createExpense(data);
      this.expense = res.expense;
      return res.expense
    },
    async deleteExpense(id: number) {
      await ExpenseAPI.deleteExpense(id);
      await this.fetchTrashesExpenses()
      await this.fetchExpenses()
    },
    async expenseRestore(id: number) {
      await ExpenseAPI.expenseRestore(id);
      await this.fetchTrashesExpenses()
    },
    async expenseDeletePermanently(id: number) {
      await ExpenseAPI.expenseDeletePermanently(id);
      await this.fetchTrashesExpenses()
    },
    async fetchPieChartDataByTag() {
      const res = await ExpenseAPI.fetchPieChartDataByTag();
      return res
    },
    async fetchTotalAmountYears(chartType: string) {
      const res = await ExpenseAPI.fetchTotalAmountYears(chartType);
      return res
    },
    async fetchPieChartDataBySubcategories(TagId: string) {
      const res = await ExpenseAPI.fetchPieChartDataBySubcategories(TagId);
      return res
    },
    async resetStates() {
      this.expense = {};
      this.expenses = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    },
  }
})