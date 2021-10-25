################################################################################
# \file CY8CKIT-064S0S2-4343W.mk
#
# \brief
# Define the CY8CKIT-064S0S2-4343W target.
#
################################################################################
# \copyright
# Copyright 2018-2021 Cypress Semiconductor Corporation (an Infineon company) or
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

# Set the default build recipe for this board if not set by the user
include $(dir $(lastword $(MAKEFILE_LIST)))/locate_recipe.mk

# MCU device selection
#    Changing the device should be done using "make bsp" or "make update_bsp" with the "DEVICE_GEN"
#    variable set to the new MCU. If you change the device manually here you must also update the
#    design.modus file and re-run the device configurator.
DEVICE:=CYS0644ABZI-S2D44
# Additional devices on the board
#    If you change the additional device here you must also update the design.modus file and re-run
#    the device configurator. You may also need to update the COMPONENT variable to include the
#    correct Wi-Fi and Bluetooth firmware.
ADDITIONAL_DEVICES:=CYW4343WKUBG
# Default target core to CM4 if not already set
CORE?=CM4
# Basic architecture specific components
COMPONENTS+=$(TARGET) CAT1 CAT1A

# Define the toolchain path. Note GCC_ARM is used for IAR in order to access
# objcopy tool for hex file creation.
ifeq ($(TOOLCHAIN),ARM)
TOOLCHAIN_PATH=$(CY_COMPILER_ARM_DIR)
else
TOOLCHAIN_PATH=$(CY_COMPILER_GCC_ARM_DIR)
endif

# Python path definition
CY_PYTHON_REQUIREMENT=true

# This only needs to run in the second stage where the CY_PYTHON_PATH gets defined
ifneq ($(CY_PYTHON_PATH),)
CY_SECURE_TOOLS_MAJOR_VERSION=$(word 1, $(subst ., ,$(filter-out , \
							  $(subst cysecuretools==, , \
							  $(shell $(CY_PYTHON_PATH) -m pip freeze | grep cysecuretools)))))
endif

ifeq ($(CORE),CM4)
# Additional components supported by the target
COMPONENTS+=TFM_S_FW TFM_NS_INTERFACE BSP_DESIGN_MODUS PSOC6HAL 4343W MURATA-1DX HCI-UART

# Use CyHAL
DEFINES+=CY_USING_HAL

# Enable Multi-Client Call feature in TF-M
DEFINES+=TFM_MULTI_CORE_MULTI_CLIENT_CALL TFM_MULTI_CORE_NS_OS

CY_LINKERSCRIPT_SUFFIX=cm4
endif

# Trusted Firmware-M Library Path
TRUSTED_FIRMWARE_M_PATH?=$(call CY_MACRO_FINDLIB,trusted-firmware-m)
ifeq ($(TRUSTED_FIRMWARE_M_PATH), NotPresent)
# Backward compatibility, try hard-coded paths instead
TRUSTED_FIRMWARE_M_PATH=$(CY_INTERNAL_APPLOC)/libs/trusted-firmware-m
endif

# Post build parameters
SECURE_BOOT_STAGE=multi
POST_BUILD_CM0_NAME?=tfm_s
POST_BUILD_CM0_LIB_PATH?=$(TRUSTED_FIRMWARE_M_PATH)/COMPONENT_TFM_S_FW
POST_BUILD_POLICY_PATH?=$(TRUSTED_FIRMWARE_M_PATH)/security/policy
ifeq ($(BOARD_TYPE),ES100)
CY_SECURE_POLICY_NAME?=policy_multi_CM0_CM4_tfm_es100
else
CY_SECURE_POLICY_NAME?=policy_multi_CM0_CM4_tfm
endif

# Check if Target BSP Library exists
POST_BUILD_BSP_LIB_PATH_INTERNAL=$(call CY_MACRO_FINDLIB,TARGET_CY8CKIT-064S0S2-4343W)
ifeq ($(POST_BUILD_BSP_LIB_PATH_INTERNAL), NotPresent)
# Backward compatibility, try hard-coded paths instead
POST_BUILD_BSP_LIB_PATH_INTERNAL=$(CY_TARGET_DIR)
endif

ifeq ($(OS),Windows_NT)
ifneq ($(CY_WHICH_CYGPATH),)
POST_BUILD_BSP_LIB_PATH=$(shell cygpath -m --absolute $(POST_BUILD_BSP_LIB_PATH_INTERNAL))
POST_BUILD_CM0_LIB_PATH_ABS=$(shell cygpath -m --absolute $(POST_BUILD_CM0_LIB_PATH))
POST_BUILD_POLICY_PATH_ABS=$(shell cygpath -m --absolute $(POST_BUILD_POLICY_PATH))
else
POST_BUILD_BSP_LIB_PATH=$(abspath $(POST_BUILD_BSP_LIB_PATH_INTERNAL))
POST_BUILD_CM0_LIB_PATH_ABS=$(abspath $(POST_BUILD_CM0_LIB_PATH))
POST_BUILD_POLICY_PATH_ABS=$(abspath $(POST_BUILD_POLICY_PATH))
endif
else
POST_BUILD_BSP_LIB_PATH=$(abspath $(POST_BUILD_BSP_LIB_PATH_INTERNAL))
POST_BUILD_CM0_LIB_PATH_ABS=$(abspath $(POST_BUILD_CM0_LIB_PATH))
POST_BUILD_POLICY_PATH_ABS=$(abspath $(POST_BUILD_POLICY_PATH))
endif

# BSP-specific post-build action
CY_BSP_POSTBUILD=$(CY_PYTHON_PATH) $(POST_BUILD_BSP_LIB_PATH)/psoc64_postbuild.py \
				--core $(CORE) \
				--secure-boot-stage $(SECURE_BOOT_STAGE) \
				--policy-path $(POST_BUILD_POLICY_PATH_ABS) \
				--policy $(CY_SECURE_POLICY_NAME) \
				--target cys06xxa \
				--toolchain-path $(TOOLCHAIN_PATH) \
				--toolchain $(TOOLCHAIN) \
				--build-dir $(CY_CONFIG_DIR) \
				--app-name $(APPNAME) \
				--cm0-app-path $(POST_BUILD_CM0_LIB_PATH_ABS) \
				--cm0-app-name $(POST_BUILD_CM0_NAME)
