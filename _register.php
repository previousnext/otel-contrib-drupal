<?php

declare(strict_types=1);

use OpenTelemetry\Contrib\Instrumentation\Drupal\DrupalInstrumentation;
use OpenTelemetry\Contrib\Instrumentation\Drupal\EntityInstrumentation;
use OpenTelemetry\Contrib\Instrumentation\Drupal\ViewsInstrumentation;
use Skpr\SkprConfig;

if (extension_loaded('opentelemetry') === false) {
    trigger_error('The opentelemetry extension must be loaded in order to autoload the OpenTelemetry Drupal auto-instrumentation', E_USER_WARNING);
    return;
}

$skpr = SkprConfig::create()->load();

if ($skpr->get('otel.drupal.enabled')) {
  DrupalInstrumentation::register();
}

if ($skpr->get('otel.drupal_views.enabled')) {
  ViewsInstrumentation::register();
}

if ($skpr->get('otel.drupal_entity.enabled')) {
  EntityInstrumentation::register();
}
