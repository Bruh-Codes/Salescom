<script setup>
import { computed, onMounted, ref } from 'vue';
import axios from 'axios';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import SettingsLayout from '../SettingsLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const route = useRoute();
const { t } = useI18n();
const billing = ref({});
const isLoading = ref(true);
const isRedirecting = ref(false);
const endpoint = computed(
  () => `/api/v1/accounts/${route.params.accountId}/billing`
);

const loadBilling = async () => {
  try {
    const { data } = await axios.get(endpoint.value);
    billing.value = data;
  } catch {
    useAlert(t('BILLING_SETTINGS.LOAD_ERROR'));
  } finally {
    isLoading.value = false;
  }
};

const redirectTo = async action => {
  isRedirecting.value = true;

  try {
    const { data } = await axios.post(`${endpoint.value}/${action}`);
    window.location.assign(data.redirect_url);
  } catch {
    isRedirecting.value = false;
    useAlert(t('BILLING_SETTINGS.REDIRECT_ERROR'));
  }
};

onMounted(loadBilling);
</script>

<template>
  <SettingsLayout :is-loading="isLoading">
    <template #header>
      <BaseSettingsHeader
        :title="$t('BILLING_SETTINGS.TITLE')"
        :description="$t('BILLING_SETTINGS.DESCRIPTION')"
      />
    </template>
    <template #body>
      <div class="rounded-xl border border-n-weak bg-n-solid-2 p-6">
        <h3 class="text-base font-medium text-n-slate-12">
          {{ $t('BILLING_SETTINGS.MANAGE_SUBSCRIPTION.TITLE') }}
        </h3>
        <p class="mt-1 text-sm text-n-slate-11">
          {{ $t('BILLING_SETTINGS.MANAGE_SUBSCRIPTION.DESCRIPTION') }}
        </p>
        <p v-if="billing.plan_name" class="mt-4 text-sm font-medium text-n-slate-12">
          <strong>{{ billing.plan_name }}</strong>
        </p>
        <p
          v-if="billing.subscription_status"
          class="mt-1 text-sm text-n-slate-11"
        >
          {{ $t('BILLING_SETTINGS.MANAGE_SUBSCRIPTION.STATUS') }}:
          {{ billing.subscription_status }}
        </p>
        <Button
          class="mt-5"
          :is-loading="isRedirecting"
          :label="
            billing.dodo_customer_id
              ? $t('BILLING_SETTINGS.MANAGE_SUBSCRIPTION.BUTTON_TXT')
              : $t('BILLING_SETTINGS.SUBSCRIBE')
          "
          @click="redirectTo(billing.dodo_customer_id ? 'portal' : 'checkout')"
        />
      </div>
    </template>
  </SettingsLayout>
</template>
