<template>
  <v-container class="min-h-screen bg-secondary p-4 rounded">
    <!-- Header -->
    <v-row justify="space-between" align="center" class="mb-6">
      <v-col cols="auto">
        <h1 class="text-2xl font-bold">Expense Tracker </h1>
      </v-col>
      <v-col cols="auto">
        <v-btn @click="openAddExpenseDialog">
          <v-icon
            size="30"
            icon="mdi mdi-plus"
            class="text-primary mr-3"
          />
          Add Expense
        </v-btn>
      </v-col>
    </v-row>

    <new-expense ref="isAddExpenseDialogOpen" @save-expense="saveExpense"/>

    <expense-table
      :expenses="expenses"
      :pagination="pagination"
      @search-expenses="searchExpenses"
      @open-trash-dialog="openTrashDialog"
      @destroy-expense="destroyExpense"
      @fetch-new-page="fetchNewPage"
      @deleteExpense="deleteExpense"
      @update-expense="updateExpense({ expense: $event }), onMountedMethod()"
    />
    <!-- Charts-->
     <div>
      <h6 class="flex justify-center font-bold mt-3">Total Expenses: {{ humanReadableCurrency(totalSpend) }}</h6>
      <div class="mt-5 flex flex-wrap gap-3 items-center justify-center">
        <BarChart v-if="totalAmountLastYears" :total-amount-last-years="totalAmountLastYears" @update-bar-chart-option="refetchTotalAmountYears" :chart-select-option="chartOption"/>
        <PieChart v-if="expensesPieChart.length" :data="expensesPieChart"/>
        <PieChart v-model:chart-select-option="chartSelectOption" :data="expensesSubcategoriesPieChart" withSelect="true" :totalAmountFormatted="SubcategoriesAmount" :tags="tags"  @update-subcategories-chart-option="updateSubcategoriesOption"/>
      </div>
     </div>
  </v-container>

  <item-trashes
    ref="isExpenseTrashesDialogOpened"
    name="expense"
    :trashesItems="trashesExpenses"
    @item-restore="expenseRestore"
    @trash-delete-permanently="expenseDeletePermanently"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia';
import { useExpenseStore } from '@/stores/my_finance_app/expense.store';
import PieChart from '@/components/chart/Pie.vue'
import BarChart from '@/components/chart/Bar.vue'
import { useMobileStore } from "@/stores/mobile";
import filters from "@/tools/filters";
import { usePopUpStore } from "@/stores/pop-up.store";
import { showToast } from '@/utils/showToast';
import ItemTrashes from '@/components/dialogs/trashItemsDialog.vue';
import {debounce} from "lodash";
import { useTagStore } from '@/stores/my_finance_app/tag.store';
import NewExpense from '@/components/my_finance_app/expense/New.vue'
import ExpenseTable from '@/components/my_finance_app/expense/Table.vue'
import moment from "moment";

const {
  fetchTags,
  createTag,
} = useTagStore();

const {
  fetchExpenses,
  fetchPieChartDataByTag,
  fetchPieChartDataBySubcategories,
  fetchTotalAmountYears,
  resetStates,
  createExpense,
  deleteExpense,
  updateExpense,
  expenseRestore,
  expenseDeletePermanently,
  fetchTrashesExpenses
} = useExpenseStore();

const { expenses, page, search, pagination, trashesExpenses } = storeToRefs(useExpenseStore());
const { tags } = storeToRefs(useTagStore());

const { isMobile } = storeToRefs(useMobileStore());
const { openPopUp, closePopUp } = usePopUpStore();

const isAddExpenseDialogOpen = ref(false)
const totalSpend = ref(0)
const tagSearchValue = ref('')
const isExpenseTrashesDialogOpened = ref(false)

// Selected currency and expense data
const totalAmountLastYears = ref(null)
const expensesPieChart = ref([])
const SubcategoriesAmount = ref(0)
const expensesSubcategoriesPieChart = ref([])
const chartSelectOption = ref(null)
const chartOption = ref('months')

const openTrashDialog = () => {
  isExpenseTrashesDialogOpened.value.isActive = true
}

const updateSubcategoriesOption = async(tag) => {
  if (tag?.id) {
    const data = await fetchPieChartDataBySubcategories(tag.id)
    expensesSubcategoriesPieChart.value = data.chart_data
    SubcategoriesAmount.value = data.total_spend
    chartSelectOption.value = tag.name
  }
}
const refetchTotalAmountYears = async(option) => {
  chartOption.value = option
  totalAmountLastYears.value = null
  totalAmountLastYears.value = await fetchTotalAmountYears(option)
}

// Function to convert the object into a human-readable format
function humanReadableCurrency(object) {
  var stringMessage = ''
  Object.entries(object).forEach(([currency, amount]) => {
    stringMessage = stringMessage + `${currency} ${amount} `;
  });
  return stringMessage
}

const destroyExpense = async(expense = {}) => {
  try {
    openPopUp({
      componentName: "pop-up-validation",
      title: ("Are you sure you want to delete this expense ?"),
      textClose: "No, cancel",
      textConfirm: "Yes, delete this expense",
      textLoading: "Deleting ...",
      icon: "mdi-trash-can-outline",
      customClass: "w-[400px]",
      showClose: false,
      async confirm() {
        try {
          await deleteExpense(expense.id)
          expenses.value =  expenses.value.filter(n => n.id !== expense.id)
          closePopUp();
          showToast(`${expense.item} expense delete successfully`, 'success');
        } catch (error) {
          // Assuming error.message contains the error message returned from the backend
          if (error.message.includes('not allowed')) {
            showToast(`Unable to delete "${expense.item}". This expense may be associated with other user and cannot be deleted.`, 'error');
          } else {
            showToast(`There was a problem deleting "${expense.item}".`, 'error');
          }
        }
      },
    });
  } catch (error) {
    console.log(error);
  }
};

onMounted(async () => {
  await onMountedMethod()
});

const onMountedMethod = async() => {
  try {
    await resetStates()
    await fetchTags();
    chartSelectOption.value = tags.value?.[0]?.name
    if (tags.value.length) {
      const subcategoriesData = await fetchPieChartDataBySubcategories(tags.value[0].id)
      expensesSubcategoriesPieChart.value = subcategoriesData.chart_data
      SubcategoriesAmount.value = subcategoriesData.total_spend
    }
    await fetchExpenses();
    await fetchTrashesExpenses();
    const data = await fetchPieChartDataByTag();
    expensesPieChart.value = data.chart_data
    totalSpend.value = data.total_spend
    totalAmountLastYears.value = await fetchTotalAmountYears('months');

  } catch (error) {
    console.log(error);
  }
}

const openAddExpenseDialog = () => {
  isAddExpenseDialogOpen.value.dialog = true
}

const saveExpense = async(expense) => {
  // expense.spent_at = expense.spent_at ? moment(expense.spent_at) : '';

  if (!expense.item) {
    showToast(`item must exist`, 'error');
    return null
  } else if (!expense.amount) {
    showToast(`amount must exist`, 'error');
    return null
  } else if (!expense.tag_id) {
    showToast(`category must exist`, 'error');
    return null
  }
  await createExpense({expense: expense })
  totalAmountLastYears.value = null
  expensesPieChart.value = []
  expensesSubcategoriesPieChart.value = []
  await onMountedMethod();
  isAddExpenseDialogOpen.value.dialog = false
}

const fetchNewPage = async(e) => {
  console.log(e)
  try {
    page.value = e
    await fetchExpenses();
  } catch (error) {
    console.log(error);
  }
};

const searchExpenses = async(e) => {
  try {
    page.value = 1
    search.value = e
    await fetchExpenses();
  } catch (error) {
    console.log(error);
  }
};
</script>

<style scoped>
/* Add any custom styles here */
</style>
