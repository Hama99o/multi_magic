<template>
  <div class="space-y-6" :class="isMobile ? 'p-1' : 'p-3'">
    <new-loan />
    <!-- Loan Tabs for Active and Archived -->
    <v-tabs v-model="activeTab" dark @change="fetchLoans">
      <v-tab>Unpaid Loans</v-tab>
      <v-tab>Paid Loans</v-tab>
    </v-tabs>

    <!-- Loan List Table -->
    <v-card-text>
      <v-tabs-window v-model="activeTab">
        <v-tabs-window-item value="unpaid">
          <v-card class="rounded-xl bg-background" :class="isMobile ? 'p-1' : 'p-6'">
            <loan-table
              :loans="loans"
              @fetch-new-page="fetchNewPage"
              @fetch-search-loans="searchLoans"
              :pagination="pagination"
              @openTrashDialog="openTrashDialog"
              @toggleArchiveLoan="toggleArchiveLoan"
              @update-loan="updateLoan({ loan: $event })"
              @deleteLoan="deleteLoan"
              @create-loan-payment="submitPayment"

            />
          </v-card>
        </v-tabs-window-item>

        <v-tabs-window-item value="paid">
          <v-card class="rounded-xl bg-background" :class="isMobile ? 'p-1' : 'p-6'">
            <loan-table
              :loans="paidLoans"
              @fetch-new-page="fetchNewPaidLoanPage"
              @fetch-search-loans="searchPaidLoans"
              :pagination="paidLoansPagination"
              @openTrashDialog="openTrashDialog"
              @toggleArchiveLoan="toggleArchiveLoan"
              @deleteLoan="deleteLoan"
              @update-loan="updateLoan({ loan: $event })"
              @create-loan-payment="submitPayment"
            />
          </v-card>
        </v-tabs-window-item>
      </v-tabs-window>
    </v-card-text>
  </div>

  <item-trashes
    ref="isLoanTrashesDialogOpened"
    name="loan"
    :trashesItems="trashesLoans"
    @item-restore="loanRestore"
    @trash-delete-permanently="loanDeletePermanently"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia';
import {debounce} from "lodash";
import { useLoanStore } from '@/stores/my_finance_app/loan.store';
import LoanTable from '@/components/my_finance_app/loan/Table.vue';
import NewLoan from '@/components/my_finance_app/loan/New.vue';
import ItemTrashes from '@/components/dialogs/trashItemsDialog.vue';

import { useMobileStore } from "@/stores/mobile";
import { showToast } from '@/utils/showToast';

const { isMobile } = storeToRefs(useMobileStore());

const {
  fetchLoans,
  fetchPieChartDataByTag,
  updateLoan,
  resetStates,
  createLoan,
  fetchPaidLoans,
  fetchTags,
  createLoanPayment,
  deleteLoan,
  loanRestore,
  loanDeletePermanently,
  fetchTrashesLoans
} = useLoanStore();

const {
  loans,
  paidLoans,
  page,
  search,
  paidLoanPage,
  paidLoanSearch,
  tags,
  pagination,
  paidLoansPagination,
  trashesLoans,
  loanType,
  paidLoanType,
} = storeToRefs(useLoanStore());

// Active Tab (0 = Active Loans, 1 = Archived Loans)
const activeTab = ref(0)
const isLoanTrashesDialogOpened = ref(null)

onMounted(async () => {
  await onMountedMethod()
});

const onMountedMethod = async() => {
  try {
    // await resetStates()
    // await fetchTags();
    await fetchLoans();
    await fetchPaidLoans()
    await fetchTrashesLoans();
    await fetchPieChartDataByTag('given', 'paid')
  } catch (error) {
    console.log(error);
  }
}

const openTrashDialog = () => {
  isLoanTrashesDialogOpened.value.isActive = true
}

const fetchNewPage = async(e, selectedLoanType) => {
  try {
    page.value = e
    loanType.value = selectedLoanType
    await fetchLoans();
  } catch (error) {
    console.log(error);
  }
};

const searchLoans = async(e, selectedLoanType) => {
  try {
    page.value = 1
    search.value = e
    loanType.value = selectedLoanType
    await fetchLoans();
  } catch (error) {
    console.log(error);
  }
};

const fetchNewPaidLoanPage = async(e, selectedLoanType) => {
  try {
    paidLoanType.value = selectedLoanType
    paidLoanPage.value = e
    await fetchPaidLoans();
  } catch (error) {
    console.log(error);
  }
};

// Toggle archive status
const toggleArchiveLoan = async (item) => {
  const loanStatus = item.status == 'paid' ? "unpaid" : "paid"
  try {
    await updateLoan({ loan:{ status: loanStatus, id: item.id}})
    // Fetch loans again to update the list
    onMountedMethod()
  } catch (error) {
    console.error('Error toggling archive status:', error)
  }
}

const searchPaidLoans = async(e, selectedLoanType) => {
  try {
    paidLoanPage.value = 1
    paidLoanSearch.value = e
    paidLoanType.value = selectedLoanType
    await fetchPaidLoans();
  } catch (error) {
    console.log(error);
  }
};

const submitPayment = async(id, data) => {
  await createLoanPayment(id, data)
};

</script>

<style scoped>
.p-6 {
  padding: 24px;
}

.space-y-6 > * + * {
  margin-top: 24px;
}
</style>
