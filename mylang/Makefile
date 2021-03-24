CXXFLAGS := -g -O0 -Wall -MD
TARGET := mylang
SRCS := main.cpp scanner.cpp parser.cpp executer.cpp ident.cpp
OBJ_DIR := obj
OBJECTS := $(SRCS:%.cpp=$(OBJ_DIR)/%.o)

all: $(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $^

-include $(OBJECTS:.o=.d)