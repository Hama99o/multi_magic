<template>
  <!-- Card Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="selectedCard">
      <v-toolbar color="primary" prominent>
        <v-btn
          icon
          @click="
            dialog = false;
            isEdit = false;
          "
        >
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Card Details</v-toolbar-title>
      </v-toolbar>

      <v-card-item>
        <div class="d-flex align-center gap-4">
          <v-avatar size="48" rounded="lg">
            <v-img
              v-if="selectedCard.link"
              :src="`https://www.google.com/s2/favicons?domain=${selectedCard.link}&sz=64`"
              :alt="selectedCard.title"
            ></v-img>
          </v-avatar>
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ selectedCard.title }}
            </v-card-title>
            <v-card-subtitle class="pa-0">
              {{ selectedCard.cardNumber }}
            </v-card-subtitle>
          </div>
        </div>
      </v-card-item>
      </v-card>
      </v-dialog>
    </template>
