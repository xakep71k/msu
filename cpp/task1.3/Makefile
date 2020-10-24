CPPFLAGS := -g -O0 -Wall
TARGET := a.out
SRC := sstack.cpp main.cpp
OBJ_DIR := obj
OBJECTS := $(SRC:%.cpp=$(OBJ_DIR)/%.o)

test: $(TARGET)
	@echo running
	./$(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.cpp sstack.h
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $^
