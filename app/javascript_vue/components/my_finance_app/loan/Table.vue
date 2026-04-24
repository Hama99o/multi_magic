<template>
  <div id="text">
    <!-- Loans Data Table -->
    <v-data-table
      :headers="isMobile ? mobileHeaders : headers"
      :items="loans"
      item-key="id"
      hide-default-footer
      class="bg-background mt-4 hidden"
      :items-per-page="-1"
      :loading="loading"
    >
      <!-- Custom Row Slot -->
      <template v-slot:item="{ item }">
        <tr @click="openEditDialog(item)" class="h-14 cursor-pointer">
          <td>{{ item.contact_name }}</td>
          <td><v-chip color="primary">{{ item.amount_with_currency }}</v-chip></td>
          <td v-if="!isMobile">{{ item.remaining_amount }}</td>
          <td v-if="!isMobile">
            <v-chip :color="item.loan_type === 'given' ? 'primary' : 'red'">
              {{ item.loan_type === 'given' ? 'given' : 'taken' }}
            </v-chip>
          </td>
          <td v-if="!isMobile">{{ item.category }}</td>
          <td v-if="!isMobile">{{ item.due_date }}</td>
          <td>
            <!-- View History Button -->
            <v-btn size="small" class="mr-1" icon @click.stop="viewHistory(item)">
              <v-icon class="text-primary">mdi-history</v-icon>
            </v-btn>
            <!-- Add Payment Button -->
            <v-btn size="small" class="mr-1" icon v-if="item.remaining_amount && item.remaining_amount > 0" @click.stop="openPaymentDialog(item)">
              <v-icon class="text-primary">mdi-plus-circle-outline</v-icon>
            </v-btn>
            <v-btn size="small" icon @click.stop="generatePDF(item)">
              <v-icon class="text-primary"> mdi mdi-download-box-outline</v-icon>
            </v-btn>
            <!-- Mark as Paid/Unpaid -->
            <!-- <v-btn
              :color="item.status == 'unpaid' ? 'grey' : 'red'"
              @click.stop="$emit('toggle-archive-loan', item)"
              size="small"
              class="custom-text-size"
              :icon="item.status == 'unpaid' ? 'mdi-archive-arrow-up-outline' : 'mdi-archive-arrow-down-outline'"
            /> -->
          </td>
        </tr>
      </template>

      <!-- No Data Slot -->
      <template v-slot:no-data>
        <v-row>
          <v-col class="text-center">
            <v-icon class="text-primary mb-2" large>mdi-file-document-outline</v-icon>
            <p>No loans found. Please create one.</p>
          </v-col>
        </v-row>
      </template>

      <!-- Top Section -->
      <template v-slot:top>
        <div class="flex justify-center items-center m-2">
          <!-- Search Bar -->
          <v-text-field
            v-model="search"
            class="w-full md:w-[258px]"
            label="Search loans"
            hide-details
            @update:model-value="$emit('fetch-search-loans', $event, selectedLoanType)"
          />

          <div>
            <!-- Loan Type Filter -->
            <v-select
              v-model="selectedLoanType"
              :items="loanTypes"
              :label="isMobile ? 'Filter' : 'Filter by Loan Type'"
              class="m-2 !w-[200px]"
              item-value="key"
              hide-details
              @update:model-value="filterLoans"
            />
          </div>

          <!-- Trash Can Icon -->
          <v-btn class="hover:bg-red-100 m-2 mr-0 !h-[56px]" dark @click="$emit('open-trash-dialog')">
            <v-icon class="text-error" size="32" icon="mdi mdi-trash-can-outline"/>
          </v-btn>
        </div>
      </template>

      <!-- Bottom Section -->
      <template v-slot:bottom>
        <div class="text-center pt-2">
          <v-pagination
            v-if="pagination"
            :model-value="pagination.current_page"
            :length="pagination.total_pages"
            theme="primary"
            variant="text"
            class="my-6 !list-none"
            @update:model-value="$emit('fetch-new-page', $event, selectedLoanType)"
          />
        </div>
      </template>
    </v-data-table>

    <!-- Payment History Modal -->
    <v-dialog v-model="historyDialog" max-width="500px">
      <v-card>
        <v-card-title>Payment History</v-card-title>
        <v-card-text>
          <v-list v-if="selectedLoan.loan_payments.length">
            <v-list-item
              v-for="payment in selectedLoan.loan_payments"
              class="hover:bg-info"
              :key="payment.id"
            >
              <v-list-item-content class="d-flex justify-space-between align-center">
                <span>{{ paymentMessage(payment) }}</span>
                <v-icon
                  @click="deletePayment(payment.id)"
                  class="text-primary cursor-pointer"
                  small
                >
                  mdi-delete
                </v-icon>
              </v-list-item-content>
            </v-list-item>
          </v-list>
          <div v-else class="text-center py-4">
            <v-icon class="text-primary mb-2" large>mdi-file-document-outline</v-icon>
            <p>No payments have been recorded yet.</p>
          </div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn class="text-error" text @click="historyDialog = false">Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Add Payment Dialog -->
    <v-dialog v-model="paymentDialog" max-width="500px">
      <v-card>
        <v-card-title>Record a Payment</v-card-title>
        <v-card-title class="text-xs">Remainin Amount is {{ selectedLoan.remaining_amount }}</v-card-title>

        <v-card-text>
          <v-form @submit.prevent="submitPayment">
            <v-text-field
              v-model="newPayment.amount"
              label="Payment Amount"
              type="number"
              prepend-inner-icon="mdi-currency-usd"
              outlined
              required
              @input="handleInput"
            />
            <v-menu
              v-model="datePickerVisible"
              :close-on-content-click="false"
              transition="scale-transition"
              offset-y
              max-width="290px"
              min-width="290px"
            >
              <template v-slot:activator="{ on, attrs }">
                <date-picker
                  ref="dateModal"
                  @save="setPaymentDate"
                  :dateValue="newPayment.payment_date"
                >
                  <template #activator="{ props }">
                    <v-text-field
                      v-model="formattedDate"
                      label="Payment Date"
                      readonly
                      @click="dateModal.dialog = true"
                      v-bind="attrs"
                      v-on="on"
                      prepend-inner-icon="mdi-calendar"
                      outlined
                      required
                    ></v-text-field>
                  </template>
                </date-picker>
              </template>
            </v-menu>
          </v-form>
        </v-card-text>
        <v-card-actions class="">
          <v-spacer></v-spacer>
          <v-btn color="red" text @click="paymentDialog = false">Cancel</v-btn>
          <v-btn color="green" text @click="submitPayment">Save</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <edit-loan
      ref="openEditLoan"
      :loan="selectedLoan"
      @save-loan="saveLoan"
      @delete-loan="$emit('delete-loan', $event)"
      @toggle-archive-loan="$emit('toggle-archive-loan', $event)"
    />
  </div>

  <div>
    <!-- Content for PDF -->
    <div ref="pdfContent" class="fixed left-[-9999px] top-[-9999px] w-[210mm] p-8 bg-white">
      <v-card class="bg-white text-black">
        <v-card-title>Loan Application Details</v-card-title>
        <v-card-text>
          <!-- Display the loan details using dynamic fields -->
          <p><strong>Description:</strong> {{ loanPdfDetails.description }}</p>
          <p><strong>Due Date:</strong> {{ loanPdfDetails.due_date ? filters.formatDate(loanPdfDetails.due_date, 'DD/MM/YYYY') : loanPdfDetails.due_date }} </p>
          <p><strong>Amount:</strong> {{ loanPdfDetails.amount_with_currency }}</p>
          <p><strong>Contact Name:</strong> {{ loanPdfDetails.contact_name }}</p>
          <p><strong>Loan Type:</strong> {{ loanPdfDetails.loan_type }}</p>
          <p><strong>Status:</strong> {{ loanPdfDetails.status }}</p>
          <p><strong>Currency:</strong> {{ loanPdfDetails.currency }}</p>
          <p><strong>Tag Category:</strong> {{ loanPdfDetails.category }}</p>
          <p><strong>Total Paid:</strong> {{ loanPdfDetails.total_paid }}</p>
          <p><strong>Remaining Amount:</strong> {{ loanPdfDetails.remaining_amount }}</p>
          <!-- If loan payments exist, display them -->
          <p><strong>Loan Payments:</strong></p>
          <ul>
            <li v-for="(payment, index) in loanPdfDetails.loan_payments" :key="index">
              Payment on {{ payment.payment_date ? filters.formatDate(loanPdfDetails.due_date, 'DD/MM/YYYY') : payment.payment_date }}: {{ payment.amount }} {{ loanPdfDetails.currency }}
            </li>
          </ul>
        </v-card-text>
      </v-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useMobileStore } from "@/stores/mobile";
import { useLoanPaymentStore } from "@/stores/my_finance_app/loan_payment.store";
import { showToast } from '@/utils/showToast';
import EditLoan from "@/components/my_finance_app/loan/Edit.vue";
import moment from "moment";
import DatePicker from '@/components/tools/DatePicker.vue';
import filters from "@/tools/filters";
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'

const pdfContent = ref(null)

const loanPdfDetails = ref({})

const assignLoaon = async (loan) => {
  loanPdfDetails.value = loan
}
const generatePDF = async (loan) => {
  await assignLoaon(loan)
  const element = pdfContent.value
  if (!element) return

  try {
    const canvas = await html2canvas(element, {
      scale: 2,
      logging: false,
      useCORS: true,
      allowTaint: true
    })

    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'a4'
    })

    const imgProps = pdf.getImageProperties(imgData)
    const pdfWidth = pdf.internal.pageSize.getWidth()
    const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width

    pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight)
    pdf.save(`${loanPdfDetails.value?.contact_name}.pdf` || 'loan_details.pdf')
  } catch (error) {
    console.error('Error generating PDF:', error)
    // You might want to show an error message to the user here
  }
}

const { isMobile } = storeToRefs(useMobileStore());

const {
  deleteLoanPayment,
} = useLoanPaymentStore();
const props = defineProps({
  loans: { type: Array, default: () => [] },
  pagination: { type: Object, default: () => {} },
  loading: { type: Boolean, default: false }
});

const emits = defineEmits(['fetch-new-page', 'fetch-search-loans', 'open-trash-dialog', 'toggle-archive-loan', 'update-loan', 'delete-loan', 'create-loan-payment']);

const pdfSelectLoan = ref({})
const search = ref('');
const selectedLoanType = ref('all');
const editDialog = ref(false);
const openEditLoan = ref(false);
const selectedLoan = ref({});
const historyDialog = ref(false);
const paymentDialog = ref(false);
const datePickerVisible = ref(false);
const newPayment = ref({ amount: '', payment_date: new Date() });
const dateModal = ref(false);

const headers = ref([
  { title: 'Name', key: 'contact_name' },
  { title: 'Amount', key: 'amount' },
  { title: 'Remaining', key: 'remain_amount' },
  { title: 'Type', key: 'loan_type' },
  { title: 'Category', key: 'category' },
  { title: 'Due Date', key: 'due_date' },
  { title: 'Actions', key: 'actions' },
]);

const mobileHeaders = [
  { title: 'Name', key: 'contact_name' },
  { title: 'Amount', key: 'amount' },
  { title: 'Actions', key: 'actions' },
];

const loanTypes = [
  { title: 'All', key: 'all' },
  { title: 'Given', key: 'given' },
  { title: 'Taken', key: 'taken' }
];

const max = 10;

const generateLoanPdf = async(loan) => {
  pdfSelectLoan.value = loan
  await generatePdf(`text`)
}
const handleInput = () => {
  if (newPayment.value.amount > selectedLoan.value.remaining_amount) {
    newPayment.value.amount = selectedLoan.value.remaining_amount;
  }
};
const filterLoans = (loanType) => {
  selectedLoanType.value = loanType;
  emits('fetch-search-loans', search.value, selectedLoanType);
};

const setPaymentDate = (e) => {
  console.log(e)
  newPayment.value.payment_date = e
};

const formattedDate = computed(() => {
  return newPayment.value.payment_date ? moment(paymentDialog.value.payment_date).format('YYYY-MM-DD') : '';
});

const viewHistory = (item) => {
  selectedLoan.value = item;
  historyDialog.value = true;
};

const deletePayment = async(id) => {
  await deleteLoanPayment(id)
  selectedLoan.value.loan_payments = selectedLoan.value.loan_payments.filter(p => p.id != id)
};

const openPaymentDialog = (item) => {
  selectedLoan.value = item;
  paymentDialog.value = true;
};

const paymentMessage = (payment) => {
  const loanType = selectedLoan.value.loan_type;
  const action = loanType === 'given' ? 'given' : 'received';

  // Check if the payment date exists and format it if it does
  const dateFormatted = payment.payment_date
    ? `on ${filters.formatDate(payment.payment_date, 'DD/MM/YYYY')}`
    : '';

  return `You have ${action} a payment of ${payment.amount} ${dateFormatted}`;
};

const submitPayment = () => {
  if (!newPayment.value.amount) {
    showToast(`amount must exist`, 'error');
    return null
  } else if (!newPayment.value.payment_date) {
    showToast(`date must exist`, 'error');
    return null
  }
  emits('create-loan-payment', selectedLoan.value.id, { loan_payment: newPayment.value });
  paymentDialog.value = false;
  newPayment.value = { amount: '', payment_date: new Date() };
};

const openEditDialog = (item) => {
  selectedLoan.value = item; // Copy the selected loan data
  openEditLoan.value.editDialog = true; // Open the dialog
};

const saveLoan = (loan) => {
  const newLoan = loan
  newLoan.due_date = moment(newLoan.due_date).format('YYYY-MM-DD')
  emits('update-loan', newLoan); // Emit an event to update the loan
  openEditLoan.value.editDialog = false; // Close the dialog
};
</script>


