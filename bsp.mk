################################################################################
# \file bsp.mk
#
# \brief
# Define the CY8CKIT-064S0S2-4343W target.
#
################################################################################
# \copyright
# Copyright 2018-2022 Cypress Semiconductor Corporation (an Infineon company) or
# an affiliate of Cypress Semiconductor Corporation
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

# Any additional components to apply when using this board.
BSP_COMPONENTS:=CY8CKIT-064S0S2-4343W TFM_S_FW TFM_NS_INTERFACE WIFI_INTERFACE_SDIO

# Any additional defines to apply when using this board.
# Enable Multi-Client Call feature in TF-M
# TFM supplies it's own prebuilt CM0P image
BSP_DEFINES:=TFM_MULTI_CORE_MULTI_CLIENT_CALL TFM_MULTI_CORE_NS_OS CY_USING_HAL CY_USING_PREBUILT_CM0P_IMAGE

# Define the toolchain path. Note GCC_ARM is used for IAR in order to access
# objcopy tool for hex file creation.
ifeq ($(TOOLCHAIN),ARM)
TOOLCHAIN_PATH=$(MTB_TOOLCHAIN_ARM__BASE_DIR)
else
TOOLCHAIN_PATH=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)
endif

# Python path definition
CY_PYTHON_REQUIREMENT=true

# Trusted Firmware-M Library Path
TRUSTED_FIRMWARE_M_PATH?=$(SEARCH_trusted-firmware-m)

# Post build parameters
SECURE_BOOT_STAGE=multi
POST_BUILD_CM0_NAME?=tfm_s
POST_BUILD_CM0_LIB_PATH?=$(TRUSTED_FIRMWARE_M_PATH)/COMPONENT_CY8CKIT-064S0S2-4343W/COMPONENT_TFM_S_FW
POST_BUILD_POLICY_PATH?=./imports/trusted-firmware-m/security/COMPONENT_CY8CKIT-064S0S2-4343W/policy

CY_SECURE_POLICY_NAME?=policy_multi_CM0_CM4_tfm

POST_BUILD_BSP_LIB_PATH_INTERNAL=$(SEARCH_TARGET_$(TARGET))

POST_BUILD_BSP_LIB_PATH=$(call mtb_path_normalize,$(POST_BUILD_BSP_LIB_PATH_INTERNAL))
POST_BUILD_CM0_LIB_PATH_ABS=$(call mtb_path_normalize,$(POST_BUILD_CM0_LIB_PATH))
POST_BUILD_POLICY_PATH_ABS=$(call mtb_path_normalize,$(POST_BUILD_POLICY_PATH))

# BSP-specific post-build action
CY_BSP_POSTBUILD=$(CY_PYTHON_PATH) $(POST_BUILD_BSP_LIB_PATH)/psoc64_postbuild.py \
				--core $(MTB_RECIPE__CORE) \
				--secure-boot-stage $(SECURE_BOOT_STAGE) \
				--policy-path $(POST_BUILD_POLICY_PATH_ABS) \
				--policy $(CY_SECURE_POLICY_NAME) \
				--target cys06xxa \
				--toolchain-path $(TOOLCHAIN_PATH) \
				--toolchain $(TOOLCHAIN) \
				--build-dir $(MTB_TOOLS__OUTPUT_CONFIG_DIR) \
				--app-name $(APPNAME) \
				--cm0-app-path $(POST_BUILD_CM0_LIB_PATH_ABS) \
				--cm0-app-name $(POST_BUILD_CM0_NAME)

################################################################################
# ALL ITEMS BELOW THIS POINT ARE AUTO GENERATED BY THE BSP ASSISTANT TOOL.
# DO NOT MODIFY DIRECTLY. CHANGES SHOULD BE MADE THROUGH THE BSP ASSISTANT.
################################################################################

# Board device selection. MPN_LIST tracks what was selected in the BSP Assistant
# All other variables are derived by BSP Assistant based on the MPN_LIST.
MPN_LIST:=CYS0644ABZI-S2D44 LBEE5KL1DX
DEVICE:=CYS0644ABZI-S2D44
ADDITIONAL_DEVICES:=CYW4343WKUBG
DEVICE_COMPONENTS:=4343W CAT1 CAT1A HCI-UART MURATA-1DX PSOC6_02
DEVICE_CYS0644ABZI-S2D44_CORES:=CORE_NAME_CM0P_0 CORE_NAME_CM4_0
DEVICE_CYS0644ABZI-S2D44_DIE:=PSoC6A2M
DEVICE_CYS0644ABZI-S2D44_FEATURES:=CM4_0_FPU_PRESENT StandardSecure
DEVICE_CYS0644ABZI-S2D44_FLASH_KB:=1856
DEVICE_CYS0644ABZI-S2D44_SRAM_KB:=1024
DEVICE_CYW4343WKUBG_DIE:=4343A1
DEVICE_CYW4343WKUBG_FLASH_KB:=0
DEVICE_CYW4343WKUBG_SRAM_KB:=512
DEVICE_LIST:=CYS0644ABZI-S2D44 CYW4343WKUBG
DEVICE_TOOL_IDS:=bsp-assistant bt-configurator capsense-configurator capsense-tuner device-configurator dfuh-tool library-manager lin-configurator ml-configurator motor-suite-gui project-creator qspi-configurator secure-policy-configurator seglcd-configurator smartio-configurator usbdev-configurator
RECIPE_DIR:=$(SEARCH_recipe-make-cat1a)
