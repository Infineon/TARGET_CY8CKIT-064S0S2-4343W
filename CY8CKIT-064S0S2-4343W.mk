################################################################################
# \file CY8CKIT-064S0S2-4343W.mk
#
# \brief
# Define the CY8CKIT-064S0S2-4343W target.
#
################################################################################
# \copyright
# Copyright 2018-2020 Cypress Semiconductor Corporation
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

# MCU device selection
DEVICE:=CYB0644ABZI-S2D44
# Additional devices on the board
ADDITIONAL_DEVICES:=CYW4343WKUBG
# Default target core to CM4 if not already set
CORE?=CM4
# Define default type of bootloading method [single, dual]
# single -> CM4 only, dual -> CM0 and CM4
SECURE_CORE_MODE=single

ifeq ($(CORE),CM4)
# Additional components supported by the target
COMPONENTS+=BSP_DESIGN_MODUS PSOC6HAL 4343W
# Use CyHAL
DEFINES+=CY_USING_HAL

ifeq ($(SECURE_CORE_MODE),single)
CY_LINKERSCRIPT_SUFFIX=cm4
CY_SECURE_POLICY_NAME=policy_single_stage_CM4
else
CY_LINKERSCRIPT_SUFFIX=cm4_dual
CY_SECURE_POLICY_NAME=policy_dual_stage_CM0p_CM4
endif

else
CY_SECURE_POLICY_NAME=policy_dual_stage_CM0p_CM4
endif

# Python path definition
ifeq ($(OS),Windows_NT)
CY_PYTHON_PATH?=python
else
CY_PYTHON_PATH?=python3
endif

# BSP-specific post-build action
# CySecureTools Image ID for CM4 Applications is 16 in case of multi-stage, 4 for single-stage,
# Image ID for CM0 Applications is always 1
ifeq ($(CORE), CM4)
ifeq ($(SECURE_CORE_MODE), single)
CY_BSP_POSTBUILD=$(CY_PYTHON_PATH) -c "import cysecuretools; \
	tools = cysecuretools.CySecureTools('cy8ckit-064s0s2-4343w', 'policy/$(CY_SECURE_POLICY_NAME).json'); \
	tools.sign_image('$(CY_CONFIG_DIR)/$(APPNAME).hex',4);"
else
CY_BSP_POSTBUILD=$(CY_PYTHON_PATH) -c "import cysecuretools; \
	tools = cysecuretools.CySecureTools('cy8ckit-064s0s2-4343w', 'policy/$(CY_SECURE_POLICY_NAME).json'); \
	tools.sign_image('$(CY_CONFIG_DIR)/$(APPNAME).hex',16);"
endif
else
CY_BSP_POSTBUILD=$(CY_PYTHON_PATH) -c "import cysecuretools; \
	tools = cysecuretools.CySecureTools('cy8ckit-064s0s2-4343w', 'policy/$(CY_SECURE_POLICY_NAME).json'); \
	tools.sign_image('$(CY_CONFIG_DIR)/$(APPNAME).hex',1);"
endif