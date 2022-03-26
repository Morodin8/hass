// Auto generated code by esphome
// ========== AUTO GENERATED INCLUDE BLOCK BEGIN ===========
#include "esphome.h"
using namespace esphome;
using std::isnan;
using std::min;
using std::max;
using namespace time;
using namespace cover;
using namespace switch_;
logger::Logger *logger_logger;
web_server_base::WebServerBase *web_server_base_webserverbase;
captive_portal::CaptivePortal *captive_portal_captiveportal;
wifi::WiFiComponent *wifi_wificomponent;
ota::OTAComponent *ota_otacomponent;
api::APIServer *api_apiserver;
using namespace api;
web_server::WebServer *web_server_webserver;
using namespace sensor;
using namespace json;
preferences::IntervalSyncer *preferences_intervalsyncer;
homeassistant::HomeassistantTime *homeassistant_time;
wifi_signal::WiFiSignalSensor *wifi_signal_wifisignalsensor;
uptime::UptimeSensor *uptime_uptimesensor;
sensor::MultiplyFilter *sensor_multiplyfilter;
cover::Cover *somfy;
cover::Cover *somfy1;
cover::Cover *somfy2;
cover::Cover *somfy3;
cover::Cover *somfy4;
template_::TemplateSwitch *template__templateswitch;
Automation<> *automation;
LambdaAction<> *lambdaaction;
template_::TemplateSwitch *template__templateswitch_2;
Automation<> *automation_2;
LambdaAction<> *lambdaaction_2;
template_::TemplateSwitch *template__templateswitch_3;
Automation<> *automation_3;
LambdaAction<> *lambdaaction_3;
template_::TemplateSwitch *template__templateswitch_4;
Automation<> *automation_4;
LambdaAction<> *lambdaaction_4;
template_::TemplateSwitch *template__templateswitch_5;
Automation<> *automation_5;
LambdaAction<> *lambdaaction_5;
template_::TemplateSwitch *template__templateswitch_6;
Automation<> *automation_6;
LambdaAction<> *lambdaaction_6;
mdns::MDNSComponent *mdns_mdnscomponent;
#define yield() esphome::yield()
#define millis() esphome::millis()
#define micros() esphome::micros()
#define delay(x) esphome::delay(x)
#define delayMicroseconds(x) esphome::delayMicroseconds(x)
#include "somfy_secrets.h"
#include "somfy_cover.h"
// ========== AUTO GENERATED INCLUDE BLOCK END ==========="

void setup() {
  // ===== DO NOT EDIT ANYTHING BELOW THIS LINE =====
  // ========== AUTO GENERATED CODE BEGIN ===========
  // async_tcp:
  //   {}
  // esphome:
  //   name: esp32-devkitc
  //   libraries:
  //   - SmartRC-CC1101-Driver-Lib@2.5.6
  //   - Somfy_Remote_Lib@0.4.0
  //   - EEPROM
  //   includes:
  //   - somfy_secrets.h
  //   - somfy_cover.h
  //   build_path: esp32-devkitc
  //   platformio_options: {}
  //   name_add_mac_suffix: false
  App.pre_setup("esp32-devkitc", __DATE__ ", " __TIME__, false);
  // time:
  // cover:
  // switch:
  // logger:
  //   id: logger_logger
  //   baud_rate: 115200
  //   tx_buffer_size: 512
  //   deassert_rts_dtr: false
  //   hardware_uart: UART0
  //   level: DEBUG
  //   logs: {}
  logger_logger = new logger::Logger(115200, 512, logger::UART_SELECTION_UART0);
  logger_logger->pre_setup();
  logger_logger->set_component_source("logger");
  App.register_component(logger_logger);
  // web_server_base:
  //   id: web_server_base_webserverbase
  web_server_base_webserverbase = new web_server_base::WebServerBase();
  web_server_base_webserverbase->set_component_source("web_server_base");
  App.register_component(web_server_base_webserverbase);
  // captive_portal:
  //   id: captive_portal_captiveportal
  //   web_server_base_id: web_server_base_webserverbase
  captive_portal_captiveportal = new captive_portal::CaptivePortal(web_server_base_webserverbase);
  captive_portal_captiveportal->set_component_source("captive_portal");
  App.register_component(captive_portal_captiveportal);
  // wifi:
  //   ap:
  //     ssid: !secret 'esp32_fallback_ssid'
  //     password: !secret 'esp32_fallback_password'
  //     id: wifi_wifiap
  //     ap_timeout: 1min
  //   id: wifi_wificomponent
  //   domain: .local
  //   reboot_timeout: 15min
  //   power_save_mode: LIGHT
  //   fast_connect: false
  //   networks:
  //   - ssid: !secret 'wifi_ssid'
  //     password: !secret 'wifi_password'
  //     id: wifi_wifiap_2
  //     priority: 0.0
  //   use_address: esp32-devkitc.local
  wifi_wificomponent = new wifi::WiFiComponent();
  wifi_wificomponent->set_use_address("esp32-devkitc.local");
  wifi::WiFiAP wifi_wifiap_2 = wifi::WiFiAP();
  wifi_wifiap_2.set_ssid("VM7336264");
  wifi_wifiap_2.set_password("j6jNnJrpjgtq");
  wifi_wifiap_2.set_priority(0.0f);
  wifi_wificomponent->add_sta(wifi_wifiap_2);
  wifi::WiFiAP wifi_wifiap = wifi::WiFiAP();
  wifi_wifiap.set_ssid("Esp32-Devkitc Fallback Hotspot");
  wifi_wifiap.set_password("kCWVKvLgYSP8");
  wifi_wificomponent->set_ap(wifi_wifiap);
  wifi_wificomponent->set_ap_timeout(60000);
  wifi_wificomponent->set_reboot_timeout(900000);
  wifi_wificomponent->set_power_save_mode(wifi::WIFI_POWER_SAVE_LIGHT);
  wifi_wificomponent->set_fast_connect(false);
  wifi_wificomponent->set_component_source("wifi");
  App.register_component(wifi_wificomponent);
  // ota:
  //   password: !secret 'ota_password'
  //   id: ota_otacomponent
  //   safe_mode: true
  //   port: 3232
  //   reboot_timeout: 5min
  //   num_attempts: 10
  ota_otacomponent = new ota::OTAComponent();
  ota_otacomponent->set_port(3232);
  ota_otacomponent->set_auth_password("c4e9d6118e22571d7dc736e286b99097");
  ota_otacomponent->set_component_source("ota");
  App.register_component(ota_otacomponent);
  if (ota_otacomponent->should_enter_safe_mode(10, 300000)) return;
  // api:
  //   password: !secret 'api_password'
  //   id: api_apiserver
  //   port: 6053
  //   reboot_timeout: 15min
  api_apiserver = new api::APIServer();
  api_apiserver->set_component_source("api");
  App.register_component(api_apiserver);
  api_apiserver->set_port(6053);
  api_apiserver->set_password("E%aRZqd=3veq/!Be");
  api_apiserver->set_reboot_timeout(900000);
  // web_server:
  //   port: 80
  //   id: web_server_webserver
  //   css_url: https:esphome.io/_static/webserver-v1.min.css
  //   js_url: https:esphome.io/_static/webserver-v1.min.js
  //   web_server_base_id: web_server_base_webserverbase
  web_server_webserver = new web_server::WebServer(web_server_base_webserverbase);
  web_server_webserver->set_component_source("web_server");
  App.register_component(web_server_webserver);
  web_server_base_webserverbase->set_port(80);
  web_server_webserver->set_css_url("https://esphome.io/_static/webserver-v1.min.css");
  web_server_webserver->set_js_url("https://esphome.io/_static/webserver-v1.min.js");
  // sensor:
  // json:
  //   {}
  // substitutions:
  //   device_name: esp32-devkitc
  // esp32:
  //   board: nodemcu-32s
  //   framework:
  //     version: 1.0.6
  //     source: ~3.10006.0
  //     platform_version: 3.3.2
  //     type: arduino
  //   variant: ESP32
  // preferences:
  //   id: preferences_intervalsyncer
  //   flash_write_interval: 60s
  preferences_intervalsyncer = new preferences::IntervalSyncer();
  preferences_intervalsyncer->set_write_interval(60000);
  preferences_intervalsyncer->set_component_source("preferences");
  App.register_component(preferences_intervalsyncer);
  // time.homeassistant:
  //   platform: homeassistant
  //   id: homeassistant_time
  //   timezone: GMT0BST,M3.5.0/1,M10.5.0
  //   update_interval: 15min
  homeassistant_time = new homeassistant::HomeassistantTime();
  homeassistant_time->set_timezone("GMT0BST,M3.5.0/1,M10.5.0");
  homeassistant_time->set_update_interval(900000);
  homeassistant_time->set_component_source("homeassistant.time");
  App.register_component(homeassistant_time);
  // sensor.wifi_signal:
  //   platform: wifi_signal
  //   name: esp32-devkitc Wifi Signal
  //   update_interval: 60s
  //   disabled_by_default: false
  //   force_update: false
  //   unit_of_measurement: dBm
  //   accuracy_decimals: 0
  //   device_class: signal_strength
  //   state_class: measurement
  //   id: wifi_signal_wifisignalsensor
  wifi_signal_wifisignalsensor = new wifi_signal::WiFiSignalSensor();
  wifi_signal_wifisignalsensor->set_update_interval(60000);
  wifi_signal_wifisignalsensor->set_component_source("wifi_signal.sensor");
  App.register_component(wifi_signal_wifisignalsensor);
  App.register_sensor(wifi_signal_wifisignalsensor);
  wifi_signal_wifisignalsensor->set_name("esp32-devkitc Wifi Signal");
  wifi_signal_wifisignalsensor->set_disabled_by_default(false);
  wifi_signal_wifisignalsensor->set_device_class("signal_strength");
  wifi_signal_wifisignalsensor->set_state_class(sensor::STATE_CLASS_MEASUREMENT);
  wifi_signal_wifisignalsensor->set_unit_of_measurement("dBm");
  wifi_signal_wifisignalsensor->set_accuracy_decimals(0);
  wifi_signal_wifisignalsensor->set_force_update(false);
  // sensor.uptime:
  //   platform: uptime
  //   name: esp32-devkitc Uptime
  //   unit_of_measurement: days
  //   update_interval: 300s
  //   accuracy_decimals: 2
  //   filters:
  //   - multiply: 1.1574e-05
  //     type_id: sensor_multiplyfilter
  //   disabled_by_default: false
  //   force_update: false
  //   icon: mdi:timer-outline
  //   state_class: total_increasing
  //   id: uptime_uptimesensor
  uptime_uptimesensor = new uptime::UptimeSensor();
  uptime_uptimesensor->set_update_interval(300000);
  uptime_uptimesensor->set_component_source("uptime.sensor");
  App.register_component(uptime_uptimesensor);
  App.register_sensor(uptime_uptimesensor);
  uptime_uptimesensor->set_name("esp32-devkitc Uptime");
  uptime_uptimesensor->set_disabled_by_default(false);
  uptime_uptimesensor->set_icon("mdi:timer-outline");
  uptime_uptimesensor->set_state_class(sensor::STATE_CLASS_TOTAL_INCREASING);
  uptime_uptimesensor->set_unit_of_measurement("days");
  uptime_uptimesensor->set_accuracy_decimals(2);
  uptime_uptimesensor->set_force_update(false);
  sensor_multiplyfilter = new sensor::MultiplyFilter(1.1574e-05f);
  uptime_uptimesensor->set_filters({sensor_multiplyfilter});
  // cover.custom:
  //   platform: custom
  //   lambda: !lambda |-
  //     auto somfy_remote = new SomfyESPRemote();
  //     somfy_remote->add_cover("somfy", "kitchen", SOMFY_REMOTE_KITCHEN);
  //     somfy_remote->add_cover("somfy", "kitchen1", SOMFY_REMOTE_KITCHEN_1);
  //     somfy_remote->add_cover("somfy", "kitchen2", SOMFY_REMOTE_KITCHEN_2);
  //     somfy_remote->add_cover("somfy", "kitchen3", SOMFY_REMOTE_KITCHEN_3);
  //     somfy_remote->add_cover("somfy", "kitchen4", SOMFY_REMOTE_KITCHEN_4);
  //     App.register_component(somfy_remote);
  //     return somfy_remote->covers;
  //   covers:
  //   - id: somfy
  //     name: Somfy Cover
  //     disabled_by_default: false
  //   - id: somfy1
  //     name: Somfy Cover1
  //     disabled_by_default: false
  //   - id: somfy2
  //     name: Somfy Cover2
  //     disabled_by_default: false
  //   - id: somfy3
  //     name: Somfy Cover3
  //     disabled_by_default: false
  //   - id: somfy4
  //     name: Somfy Cover4
  //     disabled_by_default: false
  //   id: custom_customcoverconstructor
  custom::CustomCoverConstructor custom_customcoverconstructor = custom::CustomCoverConstructor([=]() -> std::vector<cover::Cover *> {
      #line 62 "/config/esphome/esp32-devkitc.yaml"
      auto somfy_remote = new SomfyESPRemote();
      somfy_remote->add_cover("somfy", "kitchen", SOMFY_REMOTE_KITCHEN);
      somfy_remote->add_cover("somfy", "kitchen1", SOMFY_REMOTE_KITCHEN_1);
      somfy_remote->add_cover("somfy", "kitchen2", SOMFY_REMOTE_KITCHEN_2);
      somfy_remote->add_cover("somfy", "kitchen3", SOMFY_REMOTE_KITCHEN_3);
      somfy_remote->add_cover("somfy", "kitchen4", SOMFY_REMOTE_KITCHEN_4);
      App.register_component(somfy_remote);
      return somfy_remote->covers;
  });
  somfy = custom_customcoverconstructor.get_cover(0);
  App.register_cover(somfy);
  somfy->set_name("Somfy Cover");
  somfy->set_disabled_by_default(false);
  somfy1 = custom_customcoverconstructor.get_cover(1);
  App.register_cover(somfy1);
  somfy1->set_name("Somfy Cover1");
  somfy1->set_disabled_by_default(false);
  somfy2 = custom_customcoverconstructor.get_cover(2);
  App.register_cover(somfy2);
  somfy2->set_name("Somfy Cover2");
  somfy2->set_disabled_by_default(false);
  somfy3 = custom_customcoverconstructor.get_cover(3);
  App.register_cover(somfy3);
  somfy3->set_name("Somfy Cover3");
  somfy3->set_disabled_by_default(false);
  somfy4 = custom_customcoverconstructor.get_cover(4);
  App.register_cover(somfy4);
  somfy4->set_name("Somfy Cover4");
  somfy4->set_disabled_by_default(false);
  // switch.template:
  //   platform: template
  //   name: STOP
  //   turn_on_action:
  //     then:
  //     - lambda: !lambda |-
  //         ((SomfyESPCover*)id(somfy))->stop();
  //       type_id: lambdaaction
  //     trigger_id: trigger
  //     automation_id: automation
  //   disabled_by_default: false
  //   id: template__templateswitch
  //   optimistic: false
  //   assumed_state: false
  //   restore_state: false
  template__templateswitch = new template_::TemplateSwitch();
  template__templateswitch->set_component_source("template.switch");
  App.register_component(template__templateswitch);
  App.register_switch(template__templateswitch);
  template__templateswitch->set_name("STOP");
  template__templateswitch->set_disabled_by_default(false);
  automation = new Automation<>(template__templateswitch->get_turn_on_trigger());
  lambdaaction = new LambdaAction<>([=]() -> void {
      #line 88 "/config/esphome/esp32-devkitc.yaml"
      ((SomfyESPCover*)somfy)->stop();
  });
  automation->add_actions({lambdaaction});
  template__templateswitch->set_optimistic(false);
  template__templateswitch->set_assumed_state(false);
  template__templateswitch->set_restore_state(false);
  // switch.template:
  //   platform: template
  //   name: PROG
  //   turn_on_action:
  //     then:
  //     - lambda: !lambda |-
  //         ((SomfyESPCover*)id(somfy))->program();
  //       type_id: lambdaaction_2
  //     trigger_id: trigger_2
  //     automation_id: automation_2
  //   disabled_by_default: false
  //   id: template__templateswitch_2
  //   optimistic: false
  //   assumed_state: false
  //   restore_state: false
  template__templateswitch_2 = new template_::TemplateSwitch();
  template__templateswitch_2->set_component_source("template.switch");
  App.register_component(template__templateswitch_2);
  App.register_switch(template__templateswitch_2);
  template__templateswitch_2->set_name("PROG");
  template__templateswitch_2->set_disabled_by_default(false);
  automation_2 = new Automation<>(template__templateswitch_2->get_turn_on_trigger());
  lambdaaction_2 = new LambdaAction<>([=]() -> void {
      #line 93 "/config/esphome/esp32-devkitc.yaml"
      ((SomfyESPCover*)somfy)->program();
  });
  automation_2->add_actions({lambdaaction_2});
  template__templateswitch_2->set_optimistic(false);
  template__templateswitch_2->set_assumed_state(false);
  template__templateswitch_2->set_restore_state(false);
  // switch.template:
  //   platform: template
  //   name: PROG1
  //   turn_on_action:
  //     then:
  //     - lambda: !lambda |-
  //         ((SomfyESPCover*)id(somfy1))->program();
  //       type_id: lambdaaction_3
  //     trigger_id: trigger_3
  //     automation_id: automation_3
  //   disabled_by_default: false
  //   id: template__templateswitch_3
  //   optimistic: false
  //   assumed_state: false
  //   restore_state: false
  template__templateswitch_3 = new template_::TemplateSwitch();
  template__templateswitch_3->set_component_source("template.switch");
  App.register_component(template__templateswitch_3);
  App.register_switch(template__templateswitch_3);
  template__templateswitch_3->set_name("PROG1");
  template__templateswitch_3->set_disabled_by_default(false);
  automation_3 = new Automation<>(template__templateswitch_3->get_turn_on_trigger());
  lambdaaction_3 = new LambdaAction<>([=]() -> void {
      #line 98 "/config/esphome/esp32-devkitc.yaml"
      ((SomfyESPCover*)somfy1)->program();
  });
  automation_3->add_actions({lambdaaction_3});
  template__templateswitch_3->set_optimistic(false);
  template__templateswitch_3->set_assumed_state(false);
  template__templateswitch_3->set_restore_state(false);
  // switch.template:
  //   platform: template
  //   name: PROG2
  //   turn_on_action:
  //     then:
  //     - lambda: !lambda |-
  //         ((SomfyESPCover*)id(somfy2))->program();
  //       type_id: lambdaaction_4
  //     trigger_id: trigger_4
  //     automation_id: automation_4
  //   disabled_by_default: false
  //   id: template__templateswitch_4
  //   optimistic: false
  //   assumed_state: false
  //   restore_state: false
  template__templateswitch_4 = new template_::TemplateSwitch();
  template__templateswitch_4->set_component_source("template.switch");
  App.register_component(template__templateswitch_4);
  App.register_switch(template__templateswitch_4);
  template__templateswitch_4->set_name("PROG2");
  template__templateswitch_4->set_disabled_by_default(false);
  automation_4 = new Automation<>(template__templateswitch_4->get_turn_on_trigger());
  lambdaaction_4 = new LambdaAction<>([=]() -> void {
      #line 103 "/config/esphome/esp32-devkitc.yaml"
      ((SomfyESPCover*)somfy2)->program();
  });
  automation_4->add_actions({lambdaaction_4});
  template__templateswitch_4->set_optimistic(false);
  template__templateswitch_4->set_assumed_state(false);
  template__templateswitch_4->set_restore_state(false);
  // switch.template:
  //   platform: template
  //   name: PROG3
  //   turn_on_action:
  //     then:
  //     - lambda: !lambda |-
  //         ((SomfyESPCover*)id(somfy3))->program();
  //       type_id: lambdaaction_5
  //     trigger_id: trigger_5
  //     automation_id: automation_5
  //   disabled_by_default: false
  //   id: template__templateswitch_5
  //   optimistic: false
  //   assumed_state: false
  //   restore_state: false
  template__templateswitch_5 = new template_::TemplateSwitch();
  template__templateswitch_5->set_component_source("template.switch");
  App.register_component(template__templateswitch_5);
  App.register_switch(template__templateswitch_5);
  template__templateswitch_5->set_name("PROG3");
  template__templateswitch_5->set_disabled_by_default(false);
  automation_5 = new Automation<>(template__templateswitch_5->get_turn_on_trigger());
  lambdaaction_5 = new LambdaAction<>([=]() -> void {
      #line 108 "/config/esphome/esp32-devkitc.yaml"
      ((SomfyESPCover*)somfy3)->program();
  });
  automation_5->add_actions({lambdaaction_5});
  template__templateswitch_5->set_optimistic(false);
  template__templateswitch_5->set_assumed_state(false);
  template__templateswitch_5->set_restore_state(false);
  // switch.template:
  //   platform: template
  //   name: PROG4
  //   turn_on_action:
  //     then:
  //     - lambda: !lambda |-
  //         ((SomfyESPCover*)id(somfy4))->program();
  //       type_id: lambdaaction_6
  //     trigger_id: trigger_6
  //     automation_id: automation_6
  //   disabled_by_default: false
  //   id: template__templateswitch_6
  //   optimistic: false
  //   assumed_state: false
  //   restore_state: false
  template__templateswitch_6 = new template_::TemplateSwitch();
  template__templateswitch_6->set_component_source("template.switch");
  App.register_component(template__templateswitch_6);
  App.register_switch(template__templateswitch_6);
  template__templateswitch_6->set_name("PROG4");
  template__templateswitch_6->set_disabled_by_default(false);
  automation_6 = new Automation<>(template__templateswitch_6->get_turn_on_trigger());
  lambdaaction_6 = new LambdaAction<>([=]() -> void {
      #line 113 "/config/esphome/esp32-devkitc.yaml"
      ((SomfyESPCover*)somfy4)->program();
  });
  automation_6->add_actions({lambdaaction_6});
  template__templateswitch_6->set_optimistic(false);
  template__templateswitch_6->set_assumed_state(false);
  template__templateswitch_6->set_restore_state(false);
  // socket:
  //   implementation: bsd_sockets
  // mdns:
  //   id: mdns_mdnscomponent
  //   disabled: false
  mdns_mdnscomponent = new mdns::MDNSComponent();
  mdns_mdnscomponent->set_component_source("mdns");
  App.register_component(mdns_mdnscomponent);
  // =========== AUTO GENERATED CODE END ============
  // ========= YOU CAN EDIT AFTER THIS LINE =========
  App.setup();
}

void loop() {
  App.loop();
}
