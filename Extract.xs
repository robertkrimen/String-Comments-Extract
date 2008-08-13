#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <ctype.h>

int is_Space(char chr) {
    if (chr == ' ')  return 1;
    if (chr == '\t') return 1;
    return 0;
}
int is_Endspace(char chr) {
    if (chr == '\n') return 1;
    if (chr == '\r') return 1;
    if (chr == '\f') return 1;
    return 0;
}
int is_Whitespace(char chr) {
    return is_Space(chr) || is_Endspace(chr);
}
int is_Identifier(char chr) {
    if ((chr >= 'a') && (chr <= 'z')) return 1;
    if ((chr >= 'A') && (chr <= 'Z')) return 1;
    if ((chr >= '0') && (chr <= '9')) return 1;
    if (chr == '_')  return 1;
    if (chr == '$')  return 1;
    if (chr == '\\') return 1;
    if (chr > 126)   return 1;
    return 0;
}
int is_Infix(char chr) {
    if (chr == ',')  return 1;
    if (chr == ';')  return 1;
    if (chr == ':')  return 1;
    if (chr == '=')  return 1;
    if (chr == '&')  return 1;
    if (chr == '%')  return 1;
    if (chr == '*')  return 1;
    if (chr == '<')  return 1;
    if (chr == '>')  return 1;
    if (chr == '?')  return 1;
    if (chr == '|')  return 1;
    if (chr == '\n') return 1;
    return 0;
}
int is_Prefix(char chr) {
    if (chr == '{')  return 1;
    if (chr == '(')  return 1;
    if (chr == '[')  return 1;
    if (chr == '!')  return 1;
    return is_Infix(chr);
}
int is_Postfix(char chr) {
    if (chr == '}')  return 1;
    if (chr == ')')  return 1;
    if (chr == ']')  return 1;
    return is_Infix(chr);
}

typedef enum {
    NODE_EMPTY,
    NODE_WHITESPACE,
    NODE_BLOCK_COMMENT,
    NODE_LINE_COMMENT,
    NODE_IDENTIFIER,
    NODE_LITERAL,
    NODE_SIGIL
} NodeType;

struct _Node;
typedef struct _Node Node;
struct _Node {
    Node*       previous;
    Node*       next;
    char*       content;
    size_t      length;
    NodeType    type;
};

typedef struct {
    Node*       head;
    Node*       tail;
    const char* buffer;
    size_t      length;
    size_t      offset;
} cppcjs_document;


#define node_is_WHITESPACE(node)                  ((node->type == NODE_WHITESPACE))
#define node_is_BLOCK_COMMENT(node)               ((node->type == NODE_BLOCK_COMMENT))
#define node_is_LINE_COMMENT(node)                ((node->type == NODE_LINE_COMMENT))
#define node_is_IDENTIFIER(node)                  ((node->type == NODE_IDENTIFIER))
#define node_is_LITERAL(node)                     ((node->type == NODE_LITERAL))
#define node_is_SIGIL(node)                       ((node->type == NODE_SIGIL))

#define node_is_EMPTY(node)                       ((node->type == NODE_EMPTY) || (node->length==0) || (node->content=NULL))
#define node_is_COMMENT(node)                     (node_is_BLOCK_COMMENT(node) || node_is_LINE_COMMENT(node))
#define node_is_PREFIXSIGIL(node)                 (node_is_SIGIL(node) && is_Prefix(node->content[0]))
#define node_is_POSTFIXSIGIL(node)                (node_is_SIGIL(node) && is_Postfix(node->content[0]))
#define node_is_ENDSPACE(node)                    (node_is_WHITESPACE(node) && is_Endspace(node->content[0]))
#define node_is_CHAR(node,chr)                    ((node->content[0]==chr) && (node->length==1))

Node* cppcjs_alloc_node() {
    Node* node = malloc(sizeof(Node));
    node->previous = NULL;
    node->next = NULL;
    node->content = NULL;
    node->length = 0;
    node->type = NODE_EMPTY;
    return node;
}

void cppcjs_free_node(Node* node) {
    if (node->content)
        free(node->content);
    free(node);
}
void cppcjs_free_node_list(Node* head) {
    return;
    while (head) {
        Node* tmp = head->next;
        cppcjs_free_node(head);
        head = tmp;
    }
}

void cppcjs_clear_node_content(Node* node) {
    if (node->content)
        free(node->content);
    node->content = NULL;
    node->length = 0;
}

void cppcjs_set_node_content(Node* node, const char* string, size_t length) {
    size_t buffer_size = length + 1;
    cppcjs_clear_node_content(node);
    node->length = length;
    node->content = malloc( sizeof(char) * buffer_size );
    memset( node->content, 0, buffer_size );
    strncpy( node->content, string, length );
}

void cppcjs_discard_node(Node* node) {
    if (node->previous)
        node->previous->next = node->next;
    if (node->next)
        node->next->previous = node->previous;
    cppcjs_free_node(node);
}

void cppcjs_append_node(Node* element, Node* node) {
    if (element->next)
        element->next->previous = node;
    node->next = element->next;
    node->previous = element;
    element->next = node;
}

void cppcjs_collapse_node_to_whitespace(Node* node) {
    if (node->content) {
        char ws = node->content[0];
        size_t idx;
        for (idx=0; idx<node->length; idx++) {
            if (is_Endspace(node->content[idx])) {
                ws = node->content[idx];
                break;
            }
        }
        cppcjs_set_node_content(node, &ws, 1);
    }
}

void cppcjs_collapse_node_to_endspace(Node* node) {
    if (node->content) {
        char ws = 0;
        size_t idx;
        for (idx=0; idx<node->length; idx++) {
            if (is_Endspace(node->content[idx])) {
                ws = node->content[idx];
                break;
            }
        }
        cppcjs_clear_node_content(node);
        if (ws)
            cppcjs_set_node_content(node, &ws, 1);
    }
}


void _cppcjs_extract_literal(cppcjs_document* document, Node* node) {
    const char* buffer = document->buffer;
    size_t offset   = document->offset;
    char delimiter  = buffer[offset];
    /* Skip start of literal */
    offset ++;
    /* Search for end of literal */
    while (offset < document->length) {
        if (buffer[offset] == '\\') {
            /* Escaped character; skip */
            offset ++;
        }
        else if (buffer[offset] == delimiter) {
            const char* start = buffer + document->offset;
            size_t length     = offset - document->offset + 1;
            cppcjs_set_node_content(node, start, length);
            node->type = NODE_LITERAL;
            return;
        }
        /* Move onto next character */
        offset ++;
    }
    croak( "Unterminated quoted string literal" );
}

void _cppcjs_extract_block_comment(cppcjs_document* document, Node* node) {
    const char* buffer = document->buffer;
    size_t offset   = document->offset;

    /* Skip start of comment */
    offset ++;  /* Skip "/" */
    offset ++;  /* Skip "*" */

    /* Search for end of comment block */
    while (offset < document->length) {
        if (buffer[offset] == '*') {
            if (buffer[offset+1] == '/') {
                const char* start = buffer + document->offset;
                size_t length     = offset - document->offset + 2;
                cppcjs_set_node_content(node, start, length);
                node->type = NODE_BLOCK_COMMENT;
                return;
            }
        }
        /* Move onto next character */
        offset ++;
    }

    croak( "Unterminated block comment" );
}

void _cppcjs_extract_line_comment(cppcjs_document* document, Node* node) {
    const char* buffer = document->buffer;
    size_t offset   = document->offset;

    /* Skip start of comment */
    offset ++;  /* Skip "/" */
    offset ++;  /* Skip "/" */

    /* Search for end of line */
    while ((offset < document->length) && !is_Endspace(buffer[offset]))
        offset ++;

    {
        const char* start = buffer + document->offset;
        size_t length = offset - document->offset;
        cppcjs_set_node_content(node, start, length);
        node->type = NODE_LINE_COMMENT;
    }
}

void _cppcjs_extract_whitespace(cppcjs_document* document, Node* node) {
    const char* buffer = document->buffer;
    size_t offset   = document->offset;
    while ((offset < document->length) && is_Whitespace(buffer[offset]))
        offset ++;
    cppcjs_set_node_content(node, document->buffer+document->offset, offset-document->offset);
    node->type = NODE_WHITESPACE;
}

void _cppcjs_extract_Identifier(cppcjs_document* document, Node* node) {
    const char* buffer = document->buffer;
    size_t offset   = document->offset;
    while ((offset < document->length) && is_Identifier(buffer[offset]))
        offset ++;
    cppcjs_set_node_content(node, document->buffer+document->offset, offset-document->offset);
    node->type = NODE_IDENTIFIER;
}

void _cppcjs_extract_Sigil(cppcjs_document* document, Node* node) {
    cppcjs_set_node_content(node, document->buffer+document->offset, 1);
    node->type = NODE_SIGIL;
}

Node* cppcjs_tokenize_string(const char* string) {
    cppcjs_document document;

    document.head = NULL;
    document.tail = NULL;
    document.buffer = string;
    document.length = strlen(string);
    document.offset = 0;

    while ((document.offset < document.length) && (document.buffer[document.offset])) {

        Node* node = cppcjs_alloc_node();
        if (!document.head)
            document.head = node;
        if (!document.tail)
            document.tail = node;

        if (document.buffer[document.offset] == '/') {
            if (document.buffer[document.offset+1] == '*')
                _cppcjs_extract_block_comment(&document, node);
            else if (document.buffer[document.offset+1] == '/')
                _cppcjs_extract_line_comment(&document, node);
            else
                _cppcjs_extract_Sigil(&document, node);
        }
        else if ((document.buffer[document.offset] == '"') || (document.buffer[document.offset] == '\''))
            _cppcjs_extract_literal(&document, node);
        else if (is_Whitespace(document.buffer[document.offset]))
            _cppcjs_extract_whitespace(&document, node);
        else if (is_Identifier(document.buffer[document.offset]))
            _cppcjs_extract_Identifier(&document, node);
        else
            _cppcjs_extract_Sigil(&document, node);

        if (node->length) {
            document.offset += node->length;
            if (node != document.tail)
                cppcjs_append_node(document.tail, node);
            document.tail = node;
        }
        else {
            document.offset += 1;
            cppcjs_free_node(node);
        }
    }

    return document.head;
}

enum {
    PRUNE_NO,
    PRUNE_PREVIOUS,
    PRUNE_CURRENT,
    PRUNE_NEXT
};
int cppcjs_can_prune(Node* node) {

    switch (node->type) {
        case NODE_WHITESPACE:
        case NODE_BLOCK_COMMENT:
        case NODE_LINE_COMMENT:
            return PRUNE_NO;
    }

    return PRUNE_CURRENT;
}

Node* cppcjs_prune_branch(Node *head) {
    Node* current = head;
    while (current) {
        int prune = cppcjs_can_prune(current);
        Node* previous = current->previous;
        Node* next = current->next;
        switch (prune) {
            case PRUNE_PREVIOUS:
                cppcjs_discard_node(previous);
                if (previous == head)
                    previous = current;
                break;
            case PRUNE_CURRENT:
                cppcjs_discard_node(current);
                if (current == head)
                    head = previous ? previous : next;
                current = previous ? previous : next;
                break;
            case PRUNE_NEXT:
                cppcjs_discard_node(next);
                break;
            default:
                current = next;
                break;
        }
    }

    return head;
}

char* cppcjs_extract_comments(const char* string) {
    char* result;
    Node* head = cppcjs_tokenize_string(string);
    if (!head) return NULL;
    head = cppcjs_prune_branch(head);
    if (!head) return NULL;
    {
        Node* current;
        char* ptr;
        ptr = result = malloc( sizeof(char) * (strlen(string)+1) );
        current = head;
        while (current) {
            memcpy(ptr, current->content, current->length);
            ptr += current->length;
            current = current->next;
        }
        *ptr = 0;
    }
    cppcjs_free_node_list(head);
    return result;
}



MODULE = String::Comments::Extract PACKAGE = String::Comments::Extract

PROTOTYPES: disable

SV*
_cppcjs_extract_comments(string)
    SV* string
    INIT:
        char* buffer = NULL;
        RETVAL = &PL_sv_undef;
    CODE:
        buffer = cppcjs_extract_comments( SvPVX(string) );
        if (buffer != NULL) {
            RETVAL = newSVpv(buffer, 0);
            free( buffer );
        }
    OUTPUT:
        RETVAL
