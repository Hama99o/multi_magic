<template>
  <!-- Expense Form (Modal) -->
  <v-dialog v-model="dialog" max-width="600px" width="100%">
    <v-card>
      <v-card-title class="text-xl font-semibold flex justify-center items-center">Add New Expense</v-card-title>
      <v-card-text>
        <v-form ref="expenseForm" @submit.prevent="$emit('save-expense', expense)">
          <v-text-field
            v-model="expense.item"
            label="Item"
            placeholder="e.g., Groceries"
            required
            variant="solo"
          ></v-text-field>

          <v-text-field
            v-model="expense.amount"
            label="Amount"
            type="number"
            placeholder="e.g., 50.00"
            required
            variant="solo"
          ></v-text-field>

          <v-textarea
            v-model="expense.description"
            label="Description"
            placeholder="Optional description"
            rows="3"
            variant="solo"
          ></v-textarea>

          <div class="flex flex-wrap">
            <!-- Category Dropdown -->
            <v-autocomplete
              v-model="expense.tag_id"
              :items="tags"
              label="Category"
              item-title="name"
              item-value="id"
              variant="solo"
              placeholder="Select a Category"
              clearable
              hide-details
              clear-icon="mdi-close"
              @input="setSearch"
              class="mb-4"
              ref="parentTagAutocomplete"
              @update:model-value="fetchChildTags"
            >
              <!-- Custom Empty State -->
              <template v-slot:no-data>
                <v-list-item >
                  <v-list-item-content class="flex flex-col justify-center items-center gap-3">
                    <v-list-item-title class="text-center text-gray-500">
                      No categories found
                    </v-list-item-title>
                    <v-btn size="x-small" class="my-1" @click="createAndAssignTag()">Create {{ tagSearchValue }} category</v-btn>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-autocomplete>

            <!-- Subcategory Dropdown -->
            <v-autocomplete
              v-if="expense.tag_id"
              v-model="expense.subcategory_id"
              :items="childCategories"
              label="Subcategory"
              item-title="name"
              item-value="id"
              variant="solo"
              placeholder="Select a Subcategory"
              clearable
              hide-details
              clear-icon="mdi-close"
              @input="loadSubcategories"
              class="mb-4"
              ref="childTagAutocomplete"
            >
              <!-- Custom Empty State -->
              <template v-slot:no-data>
                <v-list-item >
                  <v-list-item-content class="flex flex-col justify-center items-center gap-3">
                    <v-list-item-title class="text-center text-gray-500">
                      No subcategory found
                    </v-list-item-title>
                    <v-btn size="x-small" class="my-1" @click="createAndAssignChildTag()">Create {{ tagSearchValue }} subcategory</v-btn>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-autocomplete>
          </div>

          <!-- Currency Dropdown Menu -->
          <v-select
            v-model="expense.currency"
            :items="currencies"
            label="Currency"
            variant="solo"
            item-title="code"
            placeholder="Select currency"
            class="mb-4"
          >
            <template v-slot:selection="{ item, index }">
              <span class="flex items-center">
                <span>{{ item.raw.symbol }}</span>
                <span class="ml-2">{{ item.raw.name }} ({{ item.raw.code }})</span>
              </span>
            </template>
          </v-select>

          <date-picker
            ref="dateModal"
            :date-value="expense.spent_at"
            @save="setDueDate"
            >
            <template #activator="{ props }">
              <v-text-field
                @click="dateModal.dialog = true"
                v-model="formattedDate"
                label="Spent Date"
                prepend-inner-icon="mdi-calendar"
                readonly
                v-bind="props"
                variant="solo"
                outlined
                required
              ></v-text-field>
            </template>
          </date-picker>

          <v-card-actions class="flex justify-between">
            <v-btn color="red" @click="dialog = false">Close</v-btn>
            <v-btn color="green" :disabled="isDisabled" @click="saveExpense">Save Expense</v-btn>
          </v-card-actions>
        </v-form>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useTagStore } from '@/stores/my_finance_app/tag.store';
import { debounce } from "lodash";
import { useMobileStore } from "@/stores/mobile";
import DatePicker from '@/components/tools/DatePicker.vue';
import moment from "moment";

const { isMobile } = storeToRefs(useMobileStore());
const { tags, childCategories } = storeToRefs(useTagStore());

const emits = defineEmits(['save-expense']);
const {
  fetchTags,
  createTag,
} = useTagStore();

const dialog = ref(false)
// Reference to the parentTagAutocomplete component
const parentTagAutocomplete = ref(null)
const childTagAutocomplete = ref(null)
const isDisabled = ref(false)
const tagSearchValue = ref('')
const childTagSearchValue = ref('')
const dateModal = ref(false);

const expense = ref({
  item: '',
  amount: null,
  description: '',
  tag_id: null,
  currency: 'eur',
  subcategory_id: null,
  spent_at: moment().format('YYYY-MM-DD'),
})

const formattedDate = computed(() => {
  return expense.value.spent_at ? moment(expense.value.spent_at).format('YYYY-MM-DD') : '';
});

const tagId = computed(() => {
  expense.value.subcategory_id = null
  return expense.value?.tag_id
})

const saveExpense = () => {
  isDisabled.value = true
  expense.value.spent_at = expense.value.spent_at ? moment(expense.value.spent_at).format('YYYY-MM-DD') : '';

  emits('save-expense', expense.value)
}

const setDueDate = (e) => {
  expense.value.spent_at = e
};

// Fetch subcategories when category is selected
const loadSubcategories = async (e) => {
  childTagSearchValue.value = e.target.value
  await fetchTags(e.target.value, tagId.value)
}
// Array of currency objects
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

const setSearch = debounce(async(e) => {
  tagSearchValue.value = e.target.value
  await fetchTags(e.target.value)
}, 300)

const createAndAssignTag = async() => {
  const tag = await createTag(tagSearchValue.value)
  parentTagAutocomplete.value?.blur()
  expense.value.tag_id = tag.id
  expense.value.subcategory_id = null
}

const createAndAssignChildTag = async() => {
  const tag = await createTag(childTagSearchValue.value, tagId.value)
  childTagAutocomplete.value?.blur()
  expense.value.subcategory_id = tag.id
}

const fetchChildTags = async() => {
  if (tagId.value) {
    await fetchTags(childTagSearchValue.value, tagId.value)
  } else {
    expense.value.subcategory_id = null
  }
}
defineExpose({
  dialog
})

watch(dialog, () => {
  isDisabled.value = false
  expense.value = {
    item: '',
    amount: null,
    description: '',
    tag_id: null,
    currency: 'eur',
    subcategory_id: null,
    spent_at: moment().format('YYYY-MM-DD'),
  }
})
</script>