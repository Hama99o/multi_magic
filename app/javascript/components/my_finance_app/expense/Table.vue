<template>
  <!-- Expenses List -->
  <v-card class="rounded-md shadow-md">
    <v-data-table
      :headers="isMobile ? mobileHeaders : headers"
      :items="expenses"
      class="elevation-1"
      item-value="id"
    >
      <!-- Custom Row Slot -->
      <template v-slot:item="{ item }">
        <tr
          class="h-14 bkt-bg-light-grey9-hover cursor-pointer"
          @click="openEditDialog(item)"
        >
          <!-- Define your row contents here -->
          <td>{{ item.item }}</td>
          <td>{{ item.amount_with_currency }}</td>
          <td>{{ item?.subcategory?.name ? `${item.category} (${item.subcategory?.name})`: item.category }}</td>
          <td>
            <span class="block truncate max-w-xs">{{ item.description }}</span>
          </td>
          <td><span>{{ filters.formatDate(item.spent_at, 'DD/MM/YYYY') }}</span></td>

          <td>
            <v-menu >
              <template v-slot:activator="{ props }">
                <v-icon class="text-primary" icon="mdi-dots-vertical" v-bind="props"></v-icon>
              </template>
              <v-list class="py-0">
                <div class="flex flex-col">
                  <div
                    class="cursor-pointer hover:bg-grey px-5 py-2"
                    @click.prevent="$emit('destroyExpense', item)"
                  >
                    Delete Expense
                  </div>
                </div>
                <div class="flex flex-col">
                  <div
                    class="cursor-pointer hover:bg-grey px-5 py-2"
                    @click.prevent="generatePDF(item)"
                  >
                    Download Expense PDF
                  </div>
                </div>
              </v-list>
            </v-menu>
          </td>
        </tr>
      </template>

      <template v-slot:top>
        <div class="flex justify-center items-center">
          <v-text-field
            v-model="search"
            class="w-full md:w-[258px] m-2"
            label="Search expenses"
            hide-details
            variant="solo"
            @update:model-value="$emit('search-expenses', search)"
          ></v-text-field>

        <v-btn class="hover:bg-red-100 m-2 !h-[56px]" dark @click="$emit('open-trash-dialog')">
          <v-icon class="text-error" size="32" icon="mdi mdi-trash-can-outline"/>
        </v-btn>
        </div>
      </template>


      <template v-slot:bottom>
        <div class="text-center pt-2">
          <v-pagination
            v-if="pagination"
            :model-value="pagination.current_page"
            :length="pagination.total_pages"
            theme="primary"
            variant="text"
            class="my-6 !list-none"
            @update:model-value="$emit('fetch-new-page', $event)"
          />
        </div>
      </template>
    </v-data-table>
  </v-card>

  <edit-expense
    ref="openEditExpense"
    :expense="selectedExpense"
    @save-expense="saveExpense"
    @delete-expense="$emit('delete-expense', $event)"
    @toggle-archive-expense="$emit('toggle-archive-expense', $event)"

  />

  <div ref="pdfContent" class="fixed left-[-9999px] top-[-9999px] w-[210mm] p-8 bg-white">
    <v-card class="bg-white text-black">
      <v-card-title>Expense Details</v-card-title>
      <v-card-text>
        <!-- Display the expense details using dynamic fields -->
        <p><strong>Item:</strong> {{ expensePdfDetails.item }}</p>
        <p><strong>Description:</strong> {{ expensePdfDetails.description }}</p>
        <p><strong>Amount:</strong> {{ expensePdfDetails.amount_with_currency }}</p>
        <p><strong>Currency:</strong> {{ expensePdfDetails.currency }}</p>
        <p><strong>Spent At:</strong> {{ filters.formatDate(expensePdfDetails.spent_at, 'DD/MM/YYYY') }}</p>
        <p><strong>Tag Category:</strong> {{ expensePdfDetails.category }}</p>

        <!-- If tag exists, display tag details -->
        <p><strong>Tag:</strong> {{  expensePdfDetails?.subcategory?.name ? `${expensePdfDetails.category} (${expensePdfDetails.subcategory?.name})` : 'No Tag' }}</p>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useTagStore } from '@/stores/my_finance_app/tag.store';
import { useMobileStore } from "@/stores/mobile";
import filters from "@/tools/filters";
import EditExpense from "@/components/my_finance_app/expense/Edit.vue";
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'

const props = defineProps({
  expenses: { type: Array, default: () => [] },
  pagination: { type: Object, default: () => {} }
});

const { isMobile } = storeToRefs(useMobileStore());
const { tags } = storeToRefs(useTagStore());

const expensePdfDetails = ref({})
const pdfContent = ref(false)

const assignLoaon = async (expense) => {
  expensePdfDetails.value = expense
}

const emits = defineEmits(['search-expenses', 'open-trash-dialog', 'destroy-expense', 'fetch-new-page', 'update-expense']);
const {
  fetchTags,
  createTag,
} = useTagStore();

const search = ref('')
const openEditExpense = ref(false);
const selectedExpense = ref({});

const headers = [
  { title: 'Item', key: 'item' },
  { title: 'Amount', key: 'amount_with_currency' },
  { title: 'Category', key: 'category' },
  { title: 'Description', key: 'description' },
  { title: 'Date', key: 'created_at' },
  { title: '', key: 'options' },
]

const mobileHeaders = [
  { title: 'Item', key: 'item' },
  { title: 'Amount', key: 'amount_with_currency' },
  { title: '', key: 'options' },

]

const openEditDialog = (item) => {
  selectedExpense.value = item; // Copy the selected expense data
  openEditExpense.value.editDialog = true; // Open the dialog
};

const saveExpense = (expense) => {
  emits('update-expense', expense); // Emit an event to update the expense
  openEditExpense.value.editDialog = false; // Close the dialog
};

const generatePDF = async (expense) => {
  await assignLoaon(expense)
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
    pdf.save('expense_details.pdf')
    pdf.save(`${expensePdfDetails.value?.item}.pdf` || 'expense_details.pdf')

  } catch (error) {
    console.error('Error generating PDF:', error)
    // You might want to show an error message to the user here
  }
}
</script>