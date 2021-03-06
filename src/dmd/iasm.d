/**
 * Compiler implementation of the
 * $(LINK2 http://www.dlang.org, D programming language).
 *
 *              Copyright (C) 2018 by The D Language Foundation, All Rights Reserved
 * Authors:     $(LINK2 http://www.digitalmars.com, Walter Bright)
 * License:     $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source:      $(LINK2 https://github.com/dlang/dmd/blob/master/src/dmd/iasm.d, _iasm.d)
 * Documentation:  https://dlang.org/phobos/dmd_iasm.html
 * Coverage:    https://codecov.io/gh/dlang/dmd/src/master/src/dmd/iasm.d
 */

/* Inline assembler for the D programming language compiler
 */

module dmd.iasm;

import dmd.dscope;
import dmd.func;
import dmd.statement;

version (MARS)
{
    import dmd.iasmdmd;
}
else version (IN_GCC)
{
    import dmd.iasmgcc;
}

/************************ AsmStatement ***************************************/

extern(C++) Statement asmSemantic(AsmStatement s, Scope *sc)
{
    //printf("AsmStatement.semantic()\n");

    FuncDeclaration fd = sc.parent.isFuncDeclaration();
    assert(fd);

    if (!s.tokens)
        return null;

    // Assume assembler code takes care of setting the return value
    sc.func.hasReturnExp |= 8;

    version (MARS)
    {
        auto ias = new InlineAsmStatement(s.loc, s.tokens);
        return inlineAsmSemantic(ias, sc);
    }
    else version (IN_GCC)
    {
        auto eas = new GccAsmStatement(s.loc, s.tokens);
        return gccAsmSemantic(eas, sc);
    }
    else
    {
        s.error("D inline assembler statements are not supported");
        return new ErrorStatement();
    }
}
