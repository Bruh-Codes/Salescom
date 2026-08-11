<script setup>
import { computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useStore } from 'vuex';
import { useUISettings } from 'dashboard/composables/useUISettings';

const route = useRoute();
const store = useStore();
const { uiSettings, updateUISettings } = useUISettings();

const portals = computed(() => store.getters['portals/allPortals']);

const selectedPortal = computed(() => {
  const slug =
    route.params.portalSlug || uiSettings.value.last_active_portal_slug;
  if (slug) return store.getters['portals/portalBySlug'](slug);
  return portals.value[0];
});

const defaultPortalLocale = computed(() =>
  selectedPortal.value ? selectedPortal.value.meta?.default_locale : ''
);
const selectedLocaleInPortal = computed(
  () => route.params.locale || defaultPortalLocale.value
);

const selectedPortalSlug = computed(() =>
  selectedPortal.value ? selectedPortal.value.slug : ''
);

const fetchPortalAndItsCategories = async () => {
  await store.dispatch('portals/index');
  const selectedPortalParam = {
    portalSlug: selectedPortalSlug.value,
    locale: selectedLocaleInPortal.value,
  };
  store.dispatch('portals/show', selectedPortalParam);
  store.dispatch('categories/index', selectedPortalParam);
  store.dispatch('agents/get');
};

onMounted(() => fetchPortalAndItsCategories());

watch(
  () => route.params.portalSlug,
  newSlug => {
    if (newSlug && newSlug !== uiSettings.value.last_active_portal_slug) {
      updateUISettings({
        last_active_portal_slug: newSlug,
        last_active_locale_code: selectedLocaleInPortal.value,
      });
    }
  }
);
</script>

<template>
  <div class="flex w-full h-full min-h-0">
    <section class="flex flex-1 h-full px-0 overflow-hidden bg-n-surface-1">
      <router-view />
    </section>
  </div>
</template>
