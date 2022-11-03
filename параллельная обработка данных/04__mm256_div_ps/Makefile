CXXFLAGS := -O3 -Wall -MD -mavx
TARGET := simd
SRCS := main.c
OBJ_DIR := obj
OBJECTS := $(SRCS:%.c=$(OBJ_DIR)/%.o)
LDFLAGS := 

all: $(TARGET)

.PHONY : clean
clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $^

-include $(OBJECTS:.o=.d)