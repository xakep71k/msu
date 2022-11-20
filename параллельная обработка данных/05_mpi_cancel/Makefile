CXXFLAGS := -O3 -Wall -MD
TARGET := cancel
SRCS := main.c
OBJ_DIR := obj
OBJECTS := $(SRCS:%.c=$(OBJ_DIR)/%.o)
LDFLAGS := 
CC := mpicc

all: $(TARGET)

.PHONY : clean
clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CC) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $^

-include $(OBJECTS:.o=.d)

.PHONY : run
run: $(TARGET)
	mpirun -n 4 ./$(TARGET)
