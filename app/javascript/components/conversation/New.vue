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
        <v-row class="d-flex align-center justify-center">
          <v-btn-toggle
            v-model="isGroupChat"
            color="primary"
            mandatory
            class="rounded-pill"
          >
            <v-btn :value="false" class="rounded-l-pill">
              <v-icon left>mdi-account</v-icon>
              Single User
            </v-btn>
            <v-btn :value="true" class="rounded-r-pill">
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
        <!-- Search Input / Multi-User Select for Group Chat -->
        <v-row>
          <v-col v-if="isGroupChat">
            <v-autocomplete
              ref="parentTagAutocomplete"
              v-model="selectedUsers"
              :items="searchResults"
              item-title="fullname"
              item-value="id"
              placeholder="Search for users..."
              clearable
              required
              variant="solo-filled"
              multiple
              hide-details
              clear-icon="mdi-close"
              @update:search="searchMoreUsers"
            >
            </v-autocomplete>
          </v-col>

          <v-col v-else>
            <v-text-field
              v-model="searchQuery"
              placeholder="Search for users..."
              prepend-inner-icon="mdi-magnify"
              @input="searchUsers"
              dense
              outlined
              class="mb-4"
              hide-details
            ></v-text-field>
          </v-col>
        </v-row>

        <!-- Single-User List for Direct Messages -->
        <v-list dense v-if="!isGroupChat">
          <v-list-item
            v-for="user in searchResults"
            :key="user.id"
            @click="$emit('createNewConversation', user)"
            class="flex cursor-pointer hover:bg-primary-lighten-5 rounded-lg py-2 px-3"
          >
            <!-- User Info Section -->
            <div class="flex">
              <!-- Avatar Section -->
              <user-avatar
                :isOnline="user?.is_online"
                class="cursor-pointer mr-5"
                size="lg"
                :avatar="user?.avatar"
                :firstname="user?.firstname"
                :lastname="user?.lastname"
              />
              <span>
                <v-list-item-title>{{ user.fullname }}</v-list-item-title>
                <v-list-item-subtitle>{{ user.email }}</v-list-item-subtitle>
              </span>
            </div>
          </v-list-item>
        </v-list>

        <!-- Confirmation Button -->
        <v-row v-if="isGroupChat" class="d-flex justify-end mt-4">
          <v-btn
            :disabled="isGroupChat ? selectedUsers.length === 0 : !selectedUser"
            color="primary"
            @click="confirmSelection"
          >
            <v-icon left>mdi-send</v-icon>
            Start Group Chat
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
const groupName = ref('Group Conversation')
const isGroupChat = ref(false);          // Toggle for group chat mode
const searchQuery = ref('');              // For single-user search input
const selectedUsers = ref([]);            // For selected users in group chat mode
const selectedUser = ref(null);           // For selected single user in direct chat
// Emit events to parent component
const emit = defineEmits(['searchUsers', 'createNewConversation', 'createNewGroupConversation']);

const searchUsers = () => {
  emit('searchUsers', searchQuery.value);
};

const searchMoreUsers = async (text) => {
  emit('searchUsers', text);
};

// Close the dialog
const closeDialog = () => {
  dialog.value = false;
};

// Confirm selection and start conversation
const confirmSelection = () => {
  // Emit event for group chat with multiple users
  emit('createNewGroupConversation', selectedUsers.value, groupName.value);
  closeDialog();
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog
});
</script>

<style scoped>
.dialog {
  background-color: var(--v-surface);
}
.hover\:bg-primary-lighten-5:hover {
  background-color: rgba(0, 0, 255, 0.05); /* Lightened primary color */
}
</style>
