<template>
  <!-- Edit Expense Dialog -->
  <v-dialog v-model="editDialog" max-width="600px">
    <v-card>
      <v-card-actions>
        <v-btn color="red" @click="$emit('delete-expense', selectedExpense.id); resetEdit()" class="mx-2">
          <v-icon class="text-error" left>mdi-delete</v-icon> Delete
        </v-btn>

      </v-card-actions>
      <v-card-title class="text-center">Edit Expense</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="submitExpenseForm">
          <v-row>
            <!-- Contact Name -->
            <v-col cols="12" md="6">
              <v-text-field
                v-model="selectedExpense.item"
                label="Contact Name"
                prepend-inner-icon="mdi-account"
                outlined
                required
              />
            </v-col>

            <!-- Expense Amount -->
            <v-col cols="12" md="6">
              <v-text-field
                v-model="selectedExpense.amount"
                label="Expense Amount"
                type="number"
                prepend-inner-icon="mdi-currency-usd"
                outlined
                required
              />
            </v-col>

            <!-- Category Dropdown -->
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="selectedExpense.tag_id"
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
                @update:model-value="fetchChildTags"
                ref="parentTagAutocomplete"
              >
                <!-- Custom Empty State -->
                <template v-slot:no-data>
                  <v-list-item>
                    <v-row class="flex flex-col justify-center items-center gap-1">
                      <v-col class="flex flex-col">
                        <v-list-item-title class="text-center text-gray-500">
                          No categories found
                        </v-list-item-title>
                        <v-btn size="x-small"  @click="createAndAssignTag()">Create "{{ tagSearchValue }}" category</v-btn>
                      </v-col>
                    </v-row>
                  </v-list-item>
                </template>
              </v-autocomplete>
            </v-col>

            <!-- Subcategory Dropdown -->
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="selectedExpense.subcategory_id"
                :items="childCategories"
                label="Category"
                item-title="name"
                item-value="id"
                placeholder="Select a Subcategory"
                clearable
                required
                outlined
                hide-details
                clear-icon="mdi-close"
                prepend-inner-icon="mdi-tag-plus"
                @input="loadSubcategories"
                ref="childTagAutocomplete"
              >
                <!-- Custom Empty State -->
                <template v-slot:no-data>
                  <v-list-item>
                    <v-row class="flex flex-col justify-center items-center gap-1">
                      <v-col class="flex flex-col">
                        <v-list-item-title class="text-center text-gray-500">
                          No subcategory found
                        </v-list-item-title>
                        <v-btn size="x-small"  @click="createAndAssignChildTag()">Create "{{ childTagSearchValue }}" subcategory</v-btn>
                      </v-col>
                    </v-row>
                  </v-list-item>
                </template>
              </v-autocomplete>
            </v-col>

            <!-- spent_at -->
            <v-col cols="12" md="6">
              <date-picker
              ref="dateModal"
              :date-value="selectedExpense.spent_at"
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
            </v-col>

            <!-- Currency -->
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="selectedExpense.currency"
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
            <!-- description Amount -->
            <v-col cols="12" md="6">
              <v-textarea
                v-model="selectedExpense.description"
                label="Description"
                placeholder="Optional description"
                rows="3"
              ></v-textarea>
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>

      <v-card-actions>
        <v-spacer />
        <v-btn color="blue darken-1" text @click="resetEdit" class="mx-2">
          Cancel
        </v-btn>

        <v-btn color="blue darken-1" text @click="submitExpenseForm" class="mx-2">
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
import moment from "moment";
import { useTagStore } from '@/stores/my_finance_app/tag.store';
import { debounce } from "lodash";
import { showToast } from '@/utils/showToast';
import { useExpenseStore } from '@/stores/my_finance_app/expense.store';
import DatePicker from '@/components/tools/DatePicker.vue';

const props = defineProps({
  expense: { type: Object, default: () => {} }
});

const {
  fetchExpense,
} = useExpenseStore();

const { fetchTags, createTag } = useTagStore();
const { tags, childCategories } = storeToRefs(useTagStore());

const parentTagAutocomplete = ref(null)
const childTagAutocomplete = ref(null)

const editDialog = ref(false)
const dateModal = ref(false);
const selectedExpense = ref({});
const tagSearchValue = ref('');
const childTagSearchValue = ref('')

// const { isMobile } = storeToRefs(useMobileStore())

const emit = defineEmits(['save-expense', 'delete-expense', 'toggle-archive-expense'])

const expenseTypes = ref([
  { text: 'Given', value: 'given' },
  { text: 'Taken', value: 'taken' },
]);

onMounted(async () => {
  await fetchTags();
});

const formattedDate = computed(() => {
  return selectedExpense.value.spent_at ? moment(selectedExpense.value.spent_at).format('YYYY-MM-DD') : '';
});

const setDueDate = (e) => {
  selectedExpense.value.spent_at = e
};

const createAndAssignTag = async () => {
  const tag = await createTag(tagSearchValue.value);
  selectedExpense.value.tag_id = tag.id;
  tagSearchValue.value = '';
  parentTagAutocomplete.value?.blur()
};

const tagId = computed(() => {
  selectedExpense.value.subcategory_id = null
  return selectedExpense.value?.tag_id
})

const createAndAssignChildTag = async() => {
  const tag = await createTag(childTagSearchValue.value, tagId.value)
  childTagAutocomplete.value?.blur()
  selectedExpense.value.subcategory_id = tag.id
}

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

// Fetch subcategories when category is selected
const loadSubcategories = async (e) => {
  childTagSearchValue.value = e.target.value
  await fetchTags(e.target.value, tagId.value)
}

defineExpose({
  editDialog
})

watch(props, async(newValue, oldValue) => {
  if (newValue.expense) {
    selectedExpense.value = await fetchExpense(props.expense.id)
    await fetchTags(childTagSearchValue.value, selectedExpense.value.tag_id)
    const tag_ids = tags.value.map(t => t?.id)
    if (selectedExpense.value?.tag && !tag_ids.includes(selectedExpense.value.tag.id)) {
      tags.value.unshift(selectedExpense.value.tag)
    }
  }
})

const submitExpenseForm = async () => {
  if (!selectedExpense.value.item) {
    showToast(`item must exist`, 'error');
    return null
  } else if (!selectedExpense.value.amount) {
    showToast(`amount must exist`, 'error');
    return null
  } else if (!selectedExpense.value.currency) {
    showToast(`currency must exist`, 'error');
    return null
  } else if (!selectedExpense.value.tag_id) {
    showToast(`category must exist`, 'error');
    return null
  }

  selectedExpense.value.spent_at = selectedExpense.value.spent_at ? moment(selectedExpense.value.spent_at).format('YYYY-MM-DD') : '';

  emit('save-expense', selectedExpense.value)
  resetEdit()
};

const resetEdit = () => {
  selectedExpense.value = {};
  editDialog.value = false
}

const fetchChildTags = async() => {
  if (tagId.value) {
    await fetchTags(childTagSearchValue.value, tagId.value)
  } else {
    selectedExpense.value.subcategory_id = null
  }
}
</script>