<template>
  <v-dialog v-model="dialog" max-width="600px">
    <v-card class="elevation-2 rounded-lg">
      <!-- Dialog Header -->
      <v-card-title class="d-flex justify-space-between align-center py-3">
        <span class="text-h5 font-semibold">Start New Conversation</span>
        <v-btn icon @click="dialog = false">
          <v-icon class="text-primary">mdi-close</v-icon>
        </v-btn>
      </v-card-title>

      <!-- Dialog Body -->
      <v-card-text>
        <!-- Search Input -->
        <v-text-field
          v-model="searchQuery"
          placeholder="Search for users..."
          append-icon="mdi-magnify"
          @input="$emit('searchUsers', searchQuery)"
          dense
          outlined
          class="mb-4"
          hide-details
        ></v-text-field>

        <!-- User List -->
        <v-list dense>
          <v-list-item
            v-for="user in searchResults"
            :key="user.id"
            @click="$emit('createNewConversation', user)"
            class="flex cursor-pointer hover:bg-blue-50 rounded-lg py-2 px-3"
          >
            <!-- User Info Section -->
            <div class="flex">
              <!-- Avatar Section -->
              <user-avatar
                canShowOnline
                :isOnline="user?.is_online"
                class="cursor-pointer mr-5"
                size="lg"
                :avatar="user?.avatar"
                :firstname="user?.lastname"
                :lastname="user?.firstname"
              />
              <span>
                <v-list-item-title>{{ user.fullname }}</v-list-item-title>
                <v-list-item-subtitle>{{ user.email }}</v-list-item-subtitle>
              </span>
            </div>
          </v-list-item>
        </v-list>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup>
import UserAvatar from '@/components/tools/Avatar.vue';
import { ref } from 'vue';

const props = defineProps({
  searchResults: { type: Array, default: () => [] }
});

const dialog = ref(false);

defineExpose({
  dialog
})
</script>

