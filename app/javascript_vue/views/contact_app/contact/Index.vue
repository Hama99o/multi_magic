<template>
  <div class="p-4">
    <v-card>
      <v-toolbar color="primary">
        <v-toolbar-title>Contacts</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn @click="showCreateDialog = true">Add Contact</v-btn>
        <v-btn @click="importVCard">Import vCard</v-btn>
      </v-toolbar>

      <contact-table
        :contacts="contacts"
        :pagination="pagination"
        @search-contacts="searchContacts"
        @open-trash-dialog="openTrashDialog"
        @destroy-contact="destroyContact"
        @fetch-new-page="fetchNewPage"
        @deleteContact="deleteContact"
        @exportVCard="exportVCard"
        @export-selected-contacts="exportSelectedContacts"
        @update-contact="updateContact({ contact: $event })"
      />

    </v-card>

    <v-dialog v-model="showCreateDialog">
      <v-card>
        <v-card-title>Create Contact</v-card-title>
        <v-card-text>
          <v-text-field label="First Name" v-model="form.firstname"></v-text-field>
          <v-text-field label="Last Name" v-model="form.lastname"></v-text-field>
          <v-text-field label="Email" v-model="form.email"></v-text-field>
          <v-text-field label="Phone" v-model="form.phone"></v-text-field>
          <v-text-field label="Address" v-model="form.address"></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="error darken-1" @click="showCreateDialog = false">Cancel</v-btn>
          <v-btn color="success" @click="newContact">Create</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <input type="file" ref="fileInput" @change="handleFileUpload" style="display: none;" />
  </div>

  <item-trashes
    ref="isContactTrashesDialogOpened"
    name="contact"
    :trashesItems="trashesContacts"
    @item-restore="contactRestore"
    @trash-delete-permanently="contactDeletePermanently"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia';
import { useContactStore } from '@/stores/contact_app/contact.store';
import { usePopUpStore } from "@/stores/pop-up.store";
import { showToast } from '@/utils/showToast';
import ContactTable from '@/components/contact_app/contact/Table.vue'
import ItemTrashes from '@/components/dialogs/trashItemsDialog.vue';

const {
  fetchContacts,
  resetStates,
  deleteContact,
  createContact,
  updateContact,
  contactDeletePermanently,
  contactRestore,
  fetchTrashesContacts,
  importContact,
  exportContact,
  exportMultipleContacts,
 } = useContactStore();

const { contacts, search, pagination, trashesContacts, page } = storeToRefs(useContactStore());
const { openPopUp, closePopUp } = usePopUpStore();
const isContactTrashesDialogOpened = ref(false)

const openTrashDialog = () => {
  isContactTrashesDialogOpened.value.isActive = true
}

onMounted(async () => {
  await onMountedMethod()
});

const onMountedMethod = async() => {
  try {
    await resetStates()
    await fetchContacts();
    await fetchTrashesContacts()

  } catch (error) {
    console.log(error);
  }
}

// Reactive state
const showCreateDialog = ref(false)

const form = ref({
  firstname: '',
  lastname: '',
  email: '',
  phone: '',
  address: ''
})

const newContact = async() => {
  await createContact({ contact: form.value })
}

const resetForm = () => {
  form.value = {
    firstname: '',
    lastname: '',
    email: '',
    phone: '',
    address: ''
  }
}

// Function to export selected contacts
const exportSelectedContacts = async (ids) => {
  try {
    if (ids.length === 0) {
      console.error('No contacts selected');
      return;
    }

    const response = await exportMultipleContacts(ids);

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

const exportVCard =  async(id) => {
  try {
    const response = await exportContact(id);

    // Create a Blob from the response data (which should be the vCard text)
    const blob = new Blob([response], { type: 'text/vcard' });

    // Create a URL for the Blob
    const url = window.URL.createObjectURL(blob);

    // Create a temporary anchor element and trigger the download
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `contact_${id}.vcf`); // Set the filename
    document.body.appendChild(link);
    link.click();

    // Clean up
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (error) {
    console.error('Failed to export contact:', error);
  }
}

const importVCard = () => {
  fileInput.value.click()
}

const fileInput = ref(null)

const handleFileUpload = (event) => {
  const file = event.target.files[0]
  console.log(file)
  const formData = new FormData()
  formData.append('file', file)
  importContact(formData)
}

const fetchNewPage = async(e) => {
  console.log(e)
  try {
    page.value = e
    await fetchContacts();
  } catch (error) {
    console.log(error);
  }
};

const searchContacts = async(e) => {
  try {
    page.value = 1
    search.value = e
    await fetchContacts();
  } catch (error) {
    console.log(error);
  }
};

const destroyContact = async(contact = {}) => {
  try {
    openPopUp({
      componentName: "pop-up-validation",
      title: ("Are you sure you want to delete this contact ?"),
      textClose: "No, cancel",
      textConfirm: "Yes, delete this contact",
      textLoading: "Deleting ...",
      icon: "mdi-trash-can-outline",
      customClass: "w-[400px]",
      showClose: false,
      async confirm() {
        try {
          await deleteContact(contact.id)
          contacts.value =  contacts.value.filter(n => n.id !== contact.id)
          closePopUp();
          showToast(`${contact.firstname} contact delete successfully`, 'success');
        } catch (error) {
          // Assuming error.message contains the error message returned from the backend
          if (error.message.includes('not allowed')) {
            showToast(`Unable to delete "${contact.firstname}".`, 'error');
          } else {
            showToast(`There was a problem deleting "${contact.firstname}".`, 'error');
          }
        }
      },
    });
  } catch (error) {
    console.log(error);
  }
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>
