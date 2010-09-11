== Description ==

This module can, for example, match a Lua string, Lua comment, or Lua
expression. It is useful in particular for source filters or parsing
Lua snippets embedded in another language. It is inspired by Damian
Conway's Text::Balanced [2] in Perl. The unique feature of this
implementation is that that it does not rigorously lex and parse the
Lua grammar. It doesn't need to. It assumes during the parse that the
Lua code is syntactically correct (which can be verified later using
loadstring). By assuming this, extraction of delimited sequences is
significantly simplified yet can still be robust, and it also supports
supersets of the Lua grammar. The code, which is written entirely in
Lua, is just under 200 lines of Lua code (compare to Yueliang used in
MetaLua, where the lexer alone is a few hundred lines).

== Project Page ==

Home page: http://lua-users.org/wiki/LuaBalanced

== Author ==

(c) 2008, David Manura, Licensed under the same terms as Lua (MIT license).

== References ==

[1] http://lua-users.org/wiki/LuaBalanced
[2] http://search.cpan.org/dist/Text-Balanced/lib/Text/Balanced.pm
