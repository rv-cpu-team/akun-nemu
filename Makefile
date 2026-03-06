# --- 基础路径配置 ---
NEMU_HOME ?= $(abspath .)
BUILD_DIR := $(NEMU_HOME)/build
OBJ_DIR   := $(BUILD_DIR)/obj_dir
BIN       := $(BUILD_DIR)/akun-nemu

CC  := gcc
CXX := g++
LD  := g++  # 链接时必须使用 g++ 以正确引入 C++ 标准库

# --- 编译选项 ---
INC_DIR  := $(NEMU_HOME)/include
INC_PATH := $(INC_DIR) $(INC_DIR)/utils $(INC_DIR)/riscv $(INC_DIR)/difftest $(INC_DIR)/generated
INCFLAGS := $(addprefix -I, $(INC_PATH))


CFLAGS   := $(INCFLAGS) -std=c99 -O2 -Wall -Wextra -MMD
CXXFLAGS := $(INCFLAGS) -std=c++17 -O2 -Wall -Wextra -MMD
LDFLAGS  := -lreadline -lhistory -ldl -pie $(shell llvm-config --libs)

SRC_DIR  := $(NEMU_HOME)/src
SRCS_C   := $(shell find $(SRC_DIR) -name "*.c")
SRCS_CPP := $(shell find $(SRC_DIR) -name "*.cc")

# 转换为对应的 .o 文件路径
OBJS_C   := $(SRCS_C:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
OBJS_CPP := $(SRCS_CPP:$(SRC_DIR)/%.cc=$(OBJ_DIR)/%.o)
OBJS     := $(OBJS_C) $(OBJS_CPP)
DEPS     := $(OBJS:.o=.d)

ARGS := --log=$(NEMU_HOME)/log/npc-log.txt 
ARGS += --diff=$(NEMU_HOME)/diff/riscv64-spike-so --batch


.PHONY: default all clean run gdb build-spike-diff

default: $(BIN)
all: $(BIN)

$(BIN): $(OBJS)
	@echo "[LD] $@"
	@mkdir -p $(dir $@)
	@$(LD) -o $@ $(OBJS) $(LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "[CC] $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc
	@echo "[CXX] $<"
	@mkdir -p $(dir $@)
	@$(CXX) $(CXXFLAGS) -c $< -o $@

-include $(DEPS)
build-spike-diff:
	@echo "[SPIKE]Updating spike-diff tools...$(RESET)"
	$(MAKE) -C /home/akun/akun-nemu/tools/spike-diff/ NAME=64

run: $(BIN) build-spike-diff
	@echo "[RUN] $(notdir $(BIN))"
	@$(BIN) $(ARGS)

gdb: $(BIN)
	gdb -s $(BIN) --args $(BIN) $(ARGS)

clean:
	@echo "[CLEAN] $(BUILD_DIR)"
	@rm -rf $(BUILD_DIR)

-include $(NEMU_HOME)/include/config/auto.conf
-include $(NEMU_HOME)/include/config/auto.conf.cmd
-include $(NEMU_HOME)/scripts/config.mk