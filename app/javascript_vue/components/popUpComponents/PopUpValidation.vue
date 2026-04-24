<template>
  <v-dialog max-width="500" v-model="data.open">
    <template #default>
      <div class="w-full flex flex-col p-6 gap-8 rounded-lg bg-surface">
        <!-- Close Icon -->
        <div class="relative w-full text-right">
          <v-icon
            icon="mdi mdi-close"
            width="24"
            height="24"
            class="cursor-pointer !text-primary"
            @click="closePopUp"
          />
        </div>

        <!-- Icon and Title -->
        <div class="flex flex-col items-center text-center gap-4">
          <v-icon
            icon="mdi mdi-trash-can-outline"
            width="32"
            height="32"
            class="text-primary"
          />
          <div class="font-medium text-xl">
            <p v-for="text in title" :key="text">
              {{ $t(text) }}
            </p>
          </div>
        </div>

        <!-- Buttons -->
        <div class="flex flex-col items-stretch gap-3 sm:flex-row sm:gap-x-3">
          <v-btn
            variant="flat"
            class="border-1 normal-case font-medium text-xs w-full sm:w-1/2"
            :class="{
              'text-blue-500': data.color === 'blue',
              'text-error': data.color === 'red',
              'text-primary': !data.color || data.color === 'primary'
            }"
            @click="data.sendWithoutEmail ? data.sendWithoutEmail() : closePopUp()"
          >
            {{ $t(data.textClose) }}
          </v-btn>

          <v-btn
            variant="flat"
            class="normal-case font-medium text-xs w-full sm:w-1/2"
            :class="{
              'text-blue-500': data.color === 'blue',
              'text-error': data.color === 'red',
              'text-primary': !data.color || data.color === 'primary'
            }"
            @click="confirmPopUp"
          >
            {{ $t(data.textConfirm) }}
          </v-btn>
        </div>
      </div>
    </template>
  </v-dialog>
</template>

<script setup>
import { storeToRefs } from "pinia";
import { usePopUpStore } from "@/stores/pop-up.store";
import PopUpSkeleton from "./PopUpSkeleton.vue";

const { data } = storeToRefs(usePopUpStore());
const { confirmPopUp, closePopUp } = usePopUpStore();

const title = data.value.title.split("<br/>")
const subtitle = data.value.subtitle?.split("<br/>")
</script>
