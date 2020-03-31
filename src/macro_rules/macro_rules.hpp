/*
 * MRustC - Rust Compiler
 * - By John Hodge (Mutabah/thePowersGang)
 *
 * macro_rules/macro_rules.hpp
 * - Macros by example - `macro_rules!`
 */
#ifndef MACROS_HPP_INCLUDED
#define MACROS_HPP_INCLUDED

#include "parse/lex.hpp"
#include "parse/tokentree.hpp"
#include <common.hpp>
#include <map>
#include <memory>
#include <cstring>
#include "macro_rules_ptr.hpp"
#include <set>

class MacroExpander;
class SimplePatEnt;

TAGGED_UNION(MacroExpansionEnt, Token,
    // TODO: have a "raw" stream instead of just tokens
    (Token, Token),
    // TODO: Have a flag on `NamedValue` that indicates that it is the only/last usage of this particular value (at this level)
    // NOTE: This is a 2:30 bitfield - with the high range indicating $crate
    (NamedValue, unsigned int),
    (Loop, struct {
        /// Contained entries
        ::std::vector< MacroExpansionEnt>   entries;
        /// Token used to join iterations
        Token   joiner;
        /// List of variables within this loop that control its iteration count
        /// Boolean is true if the variable will be unconditionally expanded
        ::std::map< unsigned int, bool>    variables;
        })
    );
extern ::std::ostream& operator<<(::std::ostream& os, const MacroExpansionEnt& x);

/// Matching pattern entry
struct MacroPatEnt
{
    RcString    name;
    unsigned int    name_index = 0;
    // TODO: Include a point span for the token?
    Token   tok;

    ::std::vector<MacroPatEnt>  subpats;

    enum Type {
        PAT_TOKEN,  // A token
        PAT_LOOP,   // $() Enables use of subpats

        PAT_TT, // :tt
        PAT_PAT,    // :pat
        PAT_IDENT,
        PAT_PATH,
        PAT_TYPE,
        PAT_EXPR,
        PAT_STMT,
        PAT_BLOCK,
        PAT_META,
        PAT_ITEM,   // :item
        PAT_VIS,
        PAT_LIFETIME,
        PAT_LITERAL,
    } type;

    MacroPatEnt():
        tok(TOK_NULL),
        type(PAT_TOKEN)
    {
    }
    MacroPatEnt(Token tok):
        tok( mv$(tok) ),
        type(PAT_TOKEN)
    {
    }

    MacroPatEnt(RcString name, unsigned int name_index, Type type):
        name( mv$(name) ),
        name_index( name_index ),
        tok(),
        type(type)
    {
    }

    MacroPatEnt(Token sep, const char* op, ::std::vector<MacroPatEnt> ents):
        name( op ),
        tok( mv$(sep) ),
        subpats( move(ents) ),
        type(PAT_LOOP)
    {
    }

    friend ::std::ostream& operator<<(::std::ostream& os, const MacroPatEnt& x);
    friend ::std::ostream& operator<<(::std::ostream& os, const MacroPatEnt::Type& x);
};

struct SimplePatIfCheck
{
    MacroPatEnt::Type   ty; // If PAT_TOKEN, token is checked
    Token   tok;
};

/// Simple pattern entry for macro_rules! arm patterns
TAGGED_UNION( SimplePatEnt, End,
    // End of the pattern stream (expects EOF, and terminates the match process)
    (End, struct{}),
    (LoopStart, struct{}),
    (LoopNext, struct{}),
    (LoopEnd, struct{}),
    (Jump, struct {
        size_t jump_target;
        }),
    // Expect a specific token, erroring/failing the arm if nt met
    (ExpectTok, Token),
    // Expect a pattern match
    (ExpectPat, struct {
        MacroPatEnt::Type   type;
        unsigned int    idx;
        }),
    // Compare the head of the input stream and poke the pattern stream
    (If, struct {
        bool is_equal;
        size_t  jump_target;
        ::std::vector<SimplePatIfCheck> ents;
        })
    );

extern::std::ostream& operator<<(::std::ostream& os, const SimplePatEnt& x);

/// An expansion arm within a macro_rules! blcok
struct MacroRulesArm
{
    /// Names for the parameters
    ::std::vector<RcString>   m_param_names;

    /// Patterns
    ::std::vector<SimplePatEnt> m_pattern;

    /// Rule contents
    ::std::vector<MacroExpansionEnt> m_contents;

    ~MacroRulesArm();
    MacroRulesArm()
    {}
    MacroRulesArm(::std::vector<SimplePatEnt> pattern, ::std::vector<MacroExpansionEnt> contents):
        m_pattern( mv$(pattern) ),
        m_contents( mv$(contents) )
    {}
    MacroRulesArm(const MacroRulesArm&) = delete;
    MacroRulesArm& operator=(const MacroRulesArm&) = delete;
    MacroRulesArm(MacroRulesArm&&) = default;
    MacroRulesArm& operator=(MacroRulesArm&&) = default;
};

/// A sigle 'macro_rules!' block
class MacroRules
{
public:
    /// Marks if this macro should be exported from the defining crate
    bool m_exported = false;

    /// Crate that defined this macro
    /// - Populated on deserialise if not already set
    RcString   m_source_crate;

    Ident::Hygiene  m_hygiene;

    /// Expansion rules
    ::std::vector<MacroRulesArm>  m_rules;

    MacroRules()
    {
    }
    virtual ~MacroRules();
    MacroRules(MacroRules&&) = default;
};

extern ::std::unique_ptr<TokenStream>   Macro_InvokeRules(const char *name, const MacroRules& rules, const Span& sp, TokenTree input, const AST::Crate& crate, AST::Module& mod);
extern MacroRulesPtr    Parse_MacroRules(TokenStream& lex);

extern ::std::vector<MacroPatEnt> Parse_MacroRules_Pat(TokenStream& lex, enum eTokenType open, enum eTokenType close,  ::std::vector<RcString>& names);
extern ::std::vector<MacroExpansionEnt> Parse_MacroRules_Cont(TokenStream& lex, enum eTokenType open, enum eTokenType close, const ::std::vector<RcString>& var_names, ::std::map<unsigned int,bool>* var_set_ptr=nullptr);
extern MacroRulesArm Parse_MacroRules_MakeArm(Span pat_sp, ::std::vector<MacroPatEnt> pattern, ::std::vector<MacroExpansionEnt> contents);

#endif // MACROS_HPP_INCLUDED
