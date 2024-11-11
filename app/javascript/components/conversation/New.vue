<template>
  <v-dialog v-model="dialog" max-width="600px">
    <v-card class="elevation-3 rounded-lg">
      <!-- Dialog Header -->
      <v-toolbar color="primary" dark class="rounded-t-lg">
        <v-toolbar-title class="text-h6 font-weight-bold">
          {{ isGroupChat ? 'Start New Group Chat' : 'Start New Conversation' }}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon @click="closeDialog">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-toolbar>
      <!-- Dialog Body -->
      <v-card-text>
        <!-- Conversation Mode Toggle -->
        <v-row class="d-flex align-center justify-center mb-4">
          <v-btn-toggle
            v-model="isGroupChat"
            color="primary"
            mandatory
            class="rounded-pill"
          >
            <v-btn :value="false" @click="selectedUsers = []" class="rounded-l-pill">
              <v-icon left>mdi-account</v-icon>
              Single User
            </v-btn>
            <v-btn :value="true" @click="selectedUsers = []" class="rounded-r-pill">
              <v-icon left>mdi-account-group</v-icon>
              Group Chat
            </v-btn>
          </v-btn-toggle>
        </v-row>

        <!-- Group Name Input for Group Chat Mode -->
        <v-row v-if="isGroupChat" class="mb-4">
          <v-col>
            <v-text-field
              v-model="groupName"
              label="Group Name"
              placeholder="Enter a group name..."
              dense
              outlined
              required
              hide-details
            ></v-text-field>
          </v-col>
        </v-row>

        <!-- User Selection -->
        <v-row>
          <v-col>
            <v-autocomplete
              v-model="selectedUsers"
              :items="searchResults"
              color="blue-grey-lighten-2"
              item-title="fullname"
              item-value="id"
              label="Search for users..."
              hide-details
              chips
              closable-chips
              :multiple="isGroupChat"
              @input="searchUsers"
              :custom-filter="filterByMultipleFields"
              @update:model-value="confirmSingleChat"
            >
              <template v-slot:chip="{ props, item }">
                <div v-bind="props" class="flex">
                  <v-chip
                    v-bind="props"
                    class="flex justify-center items-center gap-1"
                  >
                    <template #prepend>
                      <user-avatar
                        :isOnline="item.raw?.is_online"
                        class="cursor-pointer"
                        size="xs"
                        :avatar="item.raw?.avatar"
                        :firstname="item.raw?.firstname"
                        :lastname="item.raw?.lastname"
                      />
                    </template>

                    {{ item.raw?.fullname }}
                  </v-chip>
                </div>
              </template>

              <template v-slot:item="{ props, item }">

              <div v-bind="props" class="flex cursor-pointer p-1 hover:bg-sky-700">
                  <user-avatar
                    :isOnline="item.raw?.is_online"
                    class="mr-3"
                    size="md"
                    :avatar="item.raw?.avatar"
                    :firstname="item.raw?.firstname"
                    :lastname="item.raw?.lastname"
                  />

                  <!-- User Info -->
                  <div>
                    <v-list-item-title class="font-medium">{{ item.raw.fullname }}</v-list-item-title>
                    <v-list-item-subtitle >{{ item.raw.email }}</v-list-item-subtitle>
                  </div>
                </div>
              </template>
            </v-autocomplete>
          </v-col>
        </v-row>

        <!-- Confirmation Button -->
        <v-row v-if="isGroupChat" class="d-flex justify-end mt-4">
          <v-btn
            :disabled="isGroupChat ? !groupName || selectedUsers.length === 0 : !selectedUsers"
            color="primary"
            @click="confirmSelection"
          >
            <v-icon left>mdi-send</v-icon>
            {{ isGroupChat ? 'Start Group Chat' : 'Start Conversation' }}
          </v-btn>
        </v-row>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import UserAvatar from '@/components/tools/Avatar.vue';
import { ref, watch } from 'vue';

const props = defineProps({
  searchResults: { type: Array, default: () => [] }
});

const dialog = ref(false);
const groupName = ref('');
const isGroupChat = ref(false);
const searchQuery = ref('');
const selectedUsers = ref([]);
const emit = defineEmits(['searchUsers', 'createNewConversation', 'createNewGroupConversation']);

// Emit search input to parent
const searchUsers = (query) => {
  emit('searchUsers', query.target.value);
};

// Close dialog and reset
const closeDialog = () => {
  resetDialog();
  dialog.value = false;
};

// Reset dialog for next use
const resetDialog = () => {
  searchQuery.value = '';
  selectedUsers.value = [];
  groupName.value = '';
};

// Confirm selection for single or group chat
const confirmSelection = () => {
  if (isGroupChat.value) {
    emit('createNewGroupConversation', selectedUsers.value, groupName.value);
    closeDialog();
  }
};

// Remove selected user in group mode
const removeUser = (user) => {
  selectedUsers.value = selectedUsers.value.filter((u) => u.id !== user.id);
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog
});

const confirmSingleChat = () => {
  if (!isGroupChat.value) {
    emit('createNewConversation', selectedUsers.value);
    closeDialog();
  }
}

const filterByMultipleFields = (item, queryText) => {
  return item;
};

</script>

<style scoped>
.dialog {
  background-color: var(--v-surface);
}
.hover\:bg-primary-lighten-5:hover {
  background-color: rgba(0, 0, 255, 0.05);
}
</style>
