<template>
  <!-- Edit Loan Dialog -->
  <v-dialog v-model="editDialog" max-width="600px">
    <v-card>
      <v-card-actions>
        <v-btn color="error" @click="$emit('delete-loan', selectedLoan.id); resetEdit()" class="mx-2">
          <v-icon class="text-error" left>mdi-delete</v-icon> Delete
        </v-btn>
      </v-card-actions>
      <v-card-title class="text-center">Edit Loan</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="submitLoanForm">
          <v-row>
            <!-- Contact Name -->
            <v-col cols="12" md="6">
              <v-text-field
                v-model="selectedLoan.contact_name"
                label="Contact Name"
                prepend-inner-icon="mdi-account"
                outlined
                required
              />
            </v-col>

            <!-- Loan Amount -->
            <v-col cols="12" md="6">
              <v-text-field
                v-model="selectedLoan.amount"
                label="Loan Amount"
                type="number"
                prepend-inner-icon="mdi-currency-usd"
                outlined
                required
              />
            </v-col>

            <!-- Currency -->
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="selectedLoan.currency"
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
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="selectedLoan.tag_id"
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
                          No loan found
                        </span>
                        <v-btn size="x-small"  @click="createAndAssignTag()">Create "{{ tagSearchValue }}" category</v-btn>
                      </v-col>
                    </v-row>
                  </v-list-item>
                </template>
              </v-autocomplete>
            </v-col>

            <!-- Loan Type -->
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="selectedLoan.loan_type"
                :items="loanTypes"
                label="Loan Type"
                item-title="text"
                item-value="value"
                outlined
                required
              />
            </v-col>

            <date-picker
              ref="dateModal"
              @save="setDueDate"
              :dateValue="selectedLoan.due_date"
            >
              <template #activator="{ props }">
                <v-col cols="12" md="6">
                  <v-text-field
                    @click="dateModal.dialog = true"
                    v-model="formattedDate"
                    label="Due Date"
                    prepend-inner-icon="mdi-calendar"
                    readonly
                    outlined
                  ></v-text-field>
                </v-col>
              </template>
            </date-picker>
          </v-row>
        </v-form>
      </v-card-text>

      <v-card-actions>
        <v-spacer />
        <v-btn color="blue darken-1" text @click="resetEdit" class="mx-2">
          Cancel
        </v-btn>

        <v-btn color="blue darken-1" text @click="submitLoanForm" class="mx-2">
          Save
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { Icon } from '@iconify/vue';
import DatePicker from '@/components/tools/DatePicker.vue';
import moment from "moment";
import { useMyFinanceTagStore } from '@/stores/my_finance_app/tag.store';
import { debounce } from "lodash";
import { showToast } from '@/utils/showToast';
import { useLoanStore } from '@/stores/my_finance_app/loan.store';

const props = defineProps({
  loan: { type: Object, default: () => {} }
});

const {
  fetchLoan,
} = useLoanStore();

const { fetchTags, createTag } = useMyFinanceTagStore();
const { tags } = storeToRefs(useMyFinanceTagStore());

const autocomplete = ref(false);
const editDialog = ref(false)
const dateModal = ref(false);
const selectedLoan = ref({});
const tagSearchValue = ref('');

// const { isMobile } = storeToRefs(useMobileStore())

const emit = defineEmits(['save-loan', 'delete-loan', 'toggle-archive-loan'])

const loanTypes = ref([
  { text: 'Given', value: 'given' },
  { text: 'Taken', value: 'taken' },
]);

onMounted(async () => {
  await fetchTags();
});

const createAndAssignTag = async () => {
  const tag = await createTag(tagSearchValue.value);
  selectedLoan.value.tag_id = tag.id;
  tagSearchValue.value = '';
  autocomplete.value?.blur()
};

const setSearch = debounce(async (e) => {
  tagSearchValue.value = e.target.value;
  await fetchTags(tagSearchValue.value);
}, 300);

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

const setDueDate = (e) => {
  selectedLoan.value.due_date = e
};

const formattedDate = computed(() => {
  return selectedLoan.value.due_date ? moment(selectedLoan.value.due_date).format('YYYY-MM-DD') : '';
});

defineExpose({
  editDialog
})

watch(props, async(newValue, oldValue) => {
  if (newValue.loan) {
    selectedLoan.value = await fetchLoan(props.loan.id)
    if (selectedLoan.value?.tag && !tags.value.includes(selectedLoan.value.tag)) tags.value.unshift(selectedLoan.value.tag)
  }
})

const submitLoanForm = async () => {
  if (!selectedLoan.value.contact_name) {
    showToast(`user name must exist`, 'error');
    return null
  } else if (!selectedLoan.value.amount) {
    showToast(`amount must exist`, 'error');
    return null
  } else if (!selectedLoan.value.currency) {
    showToast(`currency must exist`, 'error');
    return null
  } else if (!selectedLoan.value.loan_type) {
    showToast(`loan type must exist`, 'error');
    return null
  } else if (!selectedLoan.value.tag_id) {
    showToast(`category must exist`, 'error');
    return null
  } else if (!selectedLoan.value.due_date) {
    showToast(`due date must exist`, 'error');
    return null
  }
  selectedLoan.value.due_date ? moment(selectedLoan.value.due_date) : '';
  emit('save-loan', selectedLoan.value)
  resetEdit()
};

const resetEdit = () => {
  selectedLoan.value = {};
  editDialog.value = false
}
</script>