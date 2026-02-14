bool SortClassMethod(const ClassMethod@const&in a, const ClassMethod@const&in b) {
    return true
        and a !is null
        and b !is null
        and a.name.ToLower() < b.name.ToLower()
    ;
}

bool SortGameClass(const GameClass@const&in a, const GameClass@const&in b) {
    return true
        and a !is null
        and b !is null
        and a.name.ToLower() < b.name.ToLower()
    ;
}
