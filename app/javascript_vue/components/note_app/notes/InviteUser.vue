<template>
  <div>
    <v-dialog max-width="500" v-model="isActive">
      <template #default>

        <div class="w-full flex flex-col p-6 gap-8 rounded-lg bg-surface">
          <!-- Icon and text -->
          <div class="flex flex-col items-center gap-4">
            <!-- icon -->
            <Icon
              icon="mdi:trash-can-outline"
              height="32"
              width="32"
            />

            <!-- Title & description -->
            <div class="flex flex-col items-center self-stretch gap-4">
              <p class="text-xl font-medium text-center">
                Invite User to share note
              </p>

              <p class="text-sm font-normal text-center">
                Invite collaborators to your notes and grow your connections.
              </p>
            </div>
          </div>

          <div>
            <v-autocomplete
              v-model="role"
              label="role"
              variant="outlined"
              :items="['viewer', 'contributor', 'administrator']"
            ></v-autocomplete>

            <v-text-field
              v-model="email"
              variant="outlined"
              label="Email address"
              placeholder="hama99o@blablaablaa.fr"
              type="email"
            ></v-text-field>
          </div>

          <!-- Buttons -->
          <div class="flex flex-col items-start gap-3 self-stretch lg:!flex-row">
            <v-btn
              color="red"
              class="normal-case text-xs w-full lg:!flex-1"
              text="cancel"
              @click="isActive = false"
            />

            <v-btn
              variant="flat"
              color="blue"
              class="normal-case text-xs w-full lg:!w-1/2"
              text="Add User"
              @click="emit('add-user', role, email, 'add')"
            />
          </div>
        </div>
      </template>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';

const role = ref('viewer')
const email = ref('')
const isActive = ref(false)
const emit = defineEmits(['add-user'])

defineExpose({
  isActive
})
</script>
