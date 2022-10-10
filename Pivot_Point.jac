walker init{
    High = .99232;
    Low = .97652;
    Close = .97652;
    report{"Highest Pice": High, "Lowest Price": Low, "Closing Price": Close};
    P = (High + Low + Close)/3;
    R1 = P + (P - Low);
    S1 = P -(High - P);
    R2 = P + (High - Low);
    S2 = P -(High - Low);
    R3 = High + (2*(P - Low));
    S3 = Low - (2*(High - P));
    std.out("The pivot point is", P);
    std.out("Support one (1) is ", S1);
    std.out("Support two (2) is ", S2);
    std.out("Support three (3) is ", S3);
    std.out("Ressitance one (1) is ",R1);
    std.out("Ressitance two (2) is ", R2);
    std.out("Ressitance three (3) is ", R3);
}