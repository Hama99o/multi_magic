<template>
  <div class="p-4 ">
    <!-- New Loan Button -->
    <v-btn
      @click="toggleForm"
      class="mb-4"
      elevation="2"
      :icon="showForm"
    >
      <v-icon class="text-primary" v-if="showForm">mdi-close</v-icon>
      <span v-else>
        New Loan
      </span>
    </v-btn>

    <!-- Sliding Loan Form -->
    <v-slide-x-transition>
      <div v-if="showForm" class="space-y-4">
        <!-- Loan Creation Form -->
        <v-card class="rounded-xlv bg-background" :class="isMobile ? 'px-3 py-6' : 'p-6'">
          <v-card-title class="text-h6 mb-4">Create New Loan</v-card-title>
          <v-form @submit.prevent="submitLoanForm">
            <v-row>
              <!-- Contact Name -->
              <v-col cols="12" md="3">
                <v-text-field
                  v-model="loan.contact_name"
                  label="Contact Name"
                  prepend-inner-icon="mdi-account"
                  outlined
                  required
                  hide-details
                ></v-text-field>
              </v-col>

              <!-- Loan Amount -->
              <v-col cols="12" md="3">
                <v-text-field
                  v-model="loan.amount"
                  label="Loan Amount"
                  type="number"
                  prepend-inner-icon="mdi-currency-usd"
                  outlined
                  hide-details
                  required
                ></v-text-field>
              </v-col>

              <!-- Currency -->
              <v-col cols="12" md="3">
                <v-autocomplete
                  v-model="loan.currency"
                  :items="currencies"
                  label="Currency"
                  item-title="code"
                  outlined
                  hide-details
                  clearable
                  prepend-inner-icon="mdi-cash"
                  clear-icon="mdi-close"
                  required
                >
                  <template v-slot:selection="{ item, index }">
                    <span class="flex items-center">
                      <span>{{ item.raw.symbol }}</span>
                      <span class="ml-2 text-nowrap">{{ item.raw.name }} ({{ item.raw.code }})</span>
                    </span>
                  </template>
                </v-autocomplete>
              </v-col>

              <!-- Category (Tag) -->
              <v-col cols="12" md="3">
                <v-autocomplete
                  v-model="loan.tag_id"
                  :items="tags"
                  label="Category"
                  item-title="name"
                  item-value="id"
                  placeholder="Select a Category"
                  clearable
                  required
                  outlined
                  hide-details
                  clear-icon="mdi-close"
                  prepend-inner-icon="mdi-tag-plus"
                  @input="setSearch"
                  ref="autocomplete"
                >
                  <!-- Custom Empty State -->
                  <template v-slot:no-data>
                    <v-list-item>
                      <v-row class="flex flex-col justify-center items-center gap-1">
                        <v-col class="flex flex-col">
                          <span class="text-center text-gray-500">
                            No categories found
                          </span>
                          <v-btn size="x-small" @click="createAndAssignTag()">Create "{{ tagSearchValue }}" category</v-btn>
                        </v-col>
                      </v-row>
                    </v-list-item>
                  </template>
                </v-autocomplete>
              </v-col>

              <!-- Loan Type -->
              <v-col cols="12" md="3">
                <v-autocomplete
                  v-model="loan.loan_type"
                  :items="loanTypes"
                  label="Loan Type"
                  item-title="text"
                  item-value="value"
                  outlined
                  hide-details
                  clearable
                  prepend-inner-icon="mdi-file-document"
                  clear-icon="mdi-close"
                  required
                ></v-autocomplete>
              </v-col>

              <date-picker
                ref="dateModal"
                :date-value="loan.due_date"
                @save="setDueDate"
              >
                <template #activator="{ props }">
                  <v-col cols="12" md="3">
                    <v-text-field
                      @click="dateModal.dialog = true"
                      v-model="formattedDate"
                      label="Due Date"
                      prepend-inner-icon="mdi-calendar"
                      readonly
                      v-bind="props"
                      outlined
                      required
                    ></v-text-field>
                  </v-col>
                </template>
              </date-picker>
            </v-row>

            <v-btn type="submit" color="primary" class="ml-4 mt-4  mb-2" elevation="2">
              Create Loan
            </v-btn>
          </v-form>
        </v-card>
      </div>
    </v-slide-x-transition>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useLoanStore } from '@/stores/my_finance_app/loan.store';
import { useTagStore } from '@/stores/my_finance_app/tag.store';
import { debounce } from "lodash";
import DatePicker from '@/components/tools/DatePicker.vue';
import moment from "moment";
import { useMobileStore } from "@/stores/mobile";
import { showToast } from '@/utils/showToast';

const { isMobile } = storeToRefs(useMobileStore());

const { fetchTags, createTag } = useTagStore();
const { tags } = storeToRefs(useTagStore());

onMounted(async () => {
  await fetchTags();
});

const tagSearchValue = ref('');
const showForm = ref(false);
const currencies = ref([
  { code: 'eur', name: 'Euro', symbol: '€' },
  { code: 'usd', name: 'United States Dollar', symbol: '$' },
  { code: 'gbp', name: 'British Pound', symbol: '£' },
  { code: 'afn', name: 'Afghan Afghani', symbol: '؋' },
  { code: 'pkr', name: 'Pakistani Rupee', symbol: '₨' },
  { code: 'inr', name: 'Indian Rupee', symbol: '₹' },
  { code: 'jpy', name: 'Japanese Yen', symbol: '¥' },
  { code: 'cny', name: 'Chinese Yuan', symbol: '¥' },
  // Add more currencies as needed
]);

const dateModal = ref(false);
const autocomplete = ref(false);

const loanTypes = ref([
  { text: 'Given', value: 'given' },
  { text: 'Taken', value: 'taken' },
]);

const { createLoan, fetchLoans } = useLoanStore();

const loan = ref({
  contact_name: '',
  amount: null,
  currency: 'eur',
  loan_type: 'taken',
  tag_id: null,
  due_date: moment().format('YYYY-MM-DD'),
});

const formattedDate = computed(() => {
  return loan.value.due_date ? moment(loan.value.due_date).format('YYYY-MM-DD') : '';
});

const submitLoanForm = async () => {
  if (!loan.value.contact_name) {
    showToast(`user name must exist`, 'error');
    return null
  } else if (!loan.value.amount) {
    showToast(`amount must exist`, 'error');
    return null
  } else if (!loan.value.currency) {
    showToast(`currency must exist`, 'error');
    return null
  } else if (!loan.value.loan_type) {
    showToast(`loan type must exist`, 'error');
    return null
  } else if (!loan.value.tag_id) {
    showToast(`category must exist`, 'error');
    return null
  } else if (!loan.value.due_date) {
    showToast(`due date must exist`, 'error');
    return null
  }

  loan.value.due_date = loan.value.due_date ? moment(loan.value.due_date).format('YYYY-MM-DD') : '';

  await createLoan({ loan: loan.value });
  await fetchLoans();

  loan.value = {
    contact_name: '',
    amount: null,
    currency: 'eur',
    loan_type: 'taken',
    tag_id: null,
    due_date: moment().format('YYYY-MM-DD'),
  };
  showForm.value = false; // Hide form after submission
};

const setSearch = debounce(async (e) => {
  tagSearchValue.value = e.target.value;
  await fetchTags(tagSearchValue.value);
}, 300);

const createAndAssignTag = async () => {
  const tag = await createTag(tagSearchValue.value);
  loan.value.tag_id = tag.id;
  tagSearchValue.value = '';
  autocomplete.value?.blur()
};

const setDueDate = (e) => {
  loan.value.due_date = e
};

const toggleForm = () => {
  showForm.value = !showForm.value;
};
</script>

<style scoped>
/* Additional styles */
</style>
