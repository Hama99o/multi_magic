<template>
  <!-- Contacts List -->
  <v-card class="rounded-md shadow-md">
    <v-data-table
      :headers="isMobile ? mobileHeaders : headers"
      :items="contacts"
      show-select
      v-model="selectedContacts"
    >
      <template v-slot:item.actions="{ item }">
        <v-menu>
          <template v-slot:activator="{ props }">
            <v-icon class="text-primary" icon="mdi-dots-vertical" v-bind="props"></v-icon>
          </template>
          <v-list class="py-0">
            <div class="flex flex-col">
              <div
                class="cursor-pointer hover:bg-grey px-5 py-2"
                @click.prevent="$emit('destroyContact', item)"
              >
                Delete Contact
              </div>
            </div>
          </v-list>

          <v-list class="py-0">
            <div class="flex flex-col">
              <div
                class="cursor-pointer hover:bg-grey px-5 py-2"
                @click.prevent="$emit('exportVCard', item.id)"
              >
                Export Contact
              </div>
            </div>
          </v-list>
        </v-menu>
      </template>

      <template v-slot:top>
        <div class="flex justify-center items-center">
          <v-btn class="hover:bg-red-100 m-2 !h-[56px]" dark @click="$emit('export-selected-contacts', selectedContacts)">
            <v-icon class="text-primary" size="32" icon="mdi mdi-export"/>
          </v-btn>

          <v-text-field
            v-model="search"
            class="w-full md:w-[258px] m-2"
            label="Search contacts"
            hide-details
            variant="solo"
            @update:model-value="$emit('search-contacts', search)"
          ></v-text-field>

          <v-btn class="hover:bg-red-100 m-2 !h-[56px]" dark @click="$emit('open-trash-dialog')">
            <v-icon class="text-primary" size="32" icon="mdi mdi-trash-can-outline"/>
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

  <edit-contact
    ref="openEditContact"
    :contact="selectedContact"
    @save-contact="saveContact"
    @delete-contact="$emit('delete-contact', $event)"
    @toggle-archive-contact="$emit('toggle-archive-contact', $event)"

  />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useMyFinanceTagStore } from '@/stores/my_finance_app/tag.store';
import { useMobileStore } from "@/stores/mobile";
import filters from "@/tools/filters";

const props = defineProps({
  contacts: { type: Array, default: () => [] },
  pagination: { type: Object, default: () => {} }
});

const { isMobile } = storeToRefs(useMobileStore());
const { tags } = storeToRefs(useMyFinanceTagStore());
const selectedContacts = ref([]);

const emits = defineEmits(['search-contacts', 'open-trash-dialog', 'destroy-contact', 'fetch-new-page', 'update-contact', 'export-selected-contacts']);
const {
  fetchTags,
  createTag,
} = useMyFinanceTagStore();

const search = ref('')
const openEditContact = ref(false);
const selectedContact = ref({});


const headers = ref([
  { title: 'Full Name', key: 'fullname' },
  { title: 'Email', key: 'email' },
  { title: 'Phone', key: 'phone' },
  { title: 'Address', key: 'address' },
  { title: 'Actions', key: 'actions', sortable: false }
])

const mobileHeaders = [
  { title: 'Full Name', key: 'fullname' },
  { title: 'Email', key: 'email' },
  { title: 'Phone', key: 'phone' },
  { title: 'Address', key: 'address' },
  { title: 'Actions', key: 'actions', sortable: false }
]

const openEditDialog = (item) => {
  selectedContact.value = item; // Copy the selected contact data
  openEditContact.value.editDialog = true; // Open the dialog
};

const saveContact = (contact) => {
  emits('update-contact', contact); // Emit an event to update the contact
  openEditContact.value.editDialog = false; // Close the dialog
};

// Function to export selected contacts
const exportSelectedContacts = async () => {
  try {
    if (selectedContacts.value.length === 0) {
      console.error('No contacts selected');
      return;
    }

    const response = await exportMultipleContacts(selectedContacts.value);

    // Create a Blob from the response data (vCard text)
    const blob = new Blob([response], { type: 'text/vcard' });

    // Create a URL for the Blob
    const url = window.URL.createObjectURL(blob);

    // Create a temporary anchor element to trigger the download
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `contacts.vcf`); // Set the filename
    document.body.appendChild(link);
    link.click();

    // Clean up
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (error) {
    console.error('Failed to export contacts:', error);
  }
};
</script>