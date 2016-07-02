#pragma once

#include <hir/type.hpp>
#include <hir/hir.hpp>

// TODO/NOTE - This is identical to ::HIR::t_cb_resolve_type
typedef ::std::function<const ::HIR::TypeRef&(const ::HIR::TypeRef&)>   t_cb_generic;

extern bool monomorphise_type_needed(const ::HIR::TypeRef& tpl);
extern bool monomorphise_pathparams_needed(const ::HIR::PathParams& tpl);
extern bool monomorphise_path_needed(const ::HIR::Path& tpl);
extern bool monomorphise_traitpath_needed(const ::HIR::TraitPath& tpl);
extern bool monomorphise_type_needed(const ::HIR::TypeRef& tpl);
extern ::HIR::PathParams monomorphise_path_params_with(const Span& sp, const ::HIR::PathParams& tpl, t_cb_generic callback, bool allow_infer);
extern ::HIR::GenericPath monomorphise_genericpath_with(const Span& sp, const ::HIR::GenericPath& tpl, t_cb_generic callback, bool allow_infer);
extern ::HIR::TraitPath monomorphise_traitpath_with(const Span& sp, const ::HIR::TraitPath& tpl, t_cb_generic callback, bool allow_infer);
extern ::HIR::TypeRef monomorphise_type_with(const Span& sp, const ::HIR::TypeRef& tpl, t_cb_generic callback, bool allow_infer=true);
extern ::HIR::TypeRef monomorphise_type(const Span& sp, const ::HIR::GenericParams& params_def, const ::HIR::PathParams& params,  const ::HIR::TypeRef& tpl);
