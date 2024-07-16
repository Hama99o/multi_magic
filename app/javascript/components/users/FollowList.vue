<template>
  <!-- Following/Followers Dialog -->
  <v-dialog v-model="dialogVisible" max-width="800px">
    <v-card>
      <v-card-title class="text-lg font-bold">
        {{ dialogTitle }}
        <v-spacer></v-spacer>
        <v-btn icon @click="closeDialog">
          <v-icon class="text-primary">mdi-close</v-icon>
        </v-btn>
      </v-card-title>

      <v-card-text>
        <v-list v-if="loading" class="text-center">
          <v-progress-circular indeterminate color="primary"></v-progress-circular>
        </v-list>

        <v-list v-else>
          <v-list-item
            v-for="user in userList"
            :key="user.id"
            class="hover:bg-gray my-2"
            @click="$emit('goToProfile', user?.id)"
          >

          <v-list-item-content class="flex gap-3 justfy-center">
              <v-list-item-avatar>
                <avatar
                  canShowOnline
                  :isOnline="user?.is_online"
                  class="cursor-pointer mr-2"
                  :avatar="user.avatar"
                  :firstname="user?.lastname"
                  :lastname="user?.firstname"
                  size="lg"
                />
              </v-list-item-avatar>
              <div>
                <v-list-item-title>{{ user.fullname }}</v-list-item-title>
                <v-list-item-subtitle>{{ user.email }}</v-list-item-subtitle>
              </div>
            </v-list-item-content>
          </v-list-item>
        </v-list>

        <v-list v-if="!loading && userList.length === 0" class="text-center">
          <p class="text-gray-500">No users to show</p>
        </v-list>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="red" text @click="closeDialog">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';
import Avatar from "@/components/tools/Avatar.vue";

const props = defineProps({
  dialogTitle: { type: String, default: '' },
  loading: { type: Boolean, default: false },
  userList: { type: Boolean, default: false }
});

const emits = defineEmits(['goToProfile'])

const dialogVisible = ref(false);

// Function to close the dialog
const closeDialog = () => {
  dialogVisible.value = false;
};

defineExpose({
  dialogVisible
})
</script>
