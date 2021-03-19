CPPFLAGS := -g -O0 -Wall
TARGET := mylang
SRC := main.cpp scanner.cpp
OBJ_DIR := obj
OBJECTS := $(SRC:%.cpp=$(OBJ_DIR)/%.o)
HEADERS := ident.h lex.h scanner.h

all: $(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.cpp $(HEADERS)
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $^