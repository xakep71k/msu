CPPFLAGS := -g -O0 -Wall
TARGET := task_1_3.out
SRC := slist.cpp add_task_1.3.cpp
OBJ_DIR := obj
OBJECTS := $(SRC:%.cpp=$(OBJ_DIR)/%.o)

test: $(TARGET)
	@echo running
	./$(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $^
