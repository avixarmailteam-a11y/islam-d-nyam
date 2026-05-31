class UserScore {
  final int totalPoints;
  final int sabahScore;
  final int ogleScore;
  final int ikindiScore;
  final int aksamScore;
  final int yatsiScore;
  final int sabahDebt;
  final int ogleDebt;
  final int ikindiDebt;
  final int aksamDebt;
  final int yatsiDebt;

  const UserScore({
    this.totalPoints = 0,
    this.sabahScore = 0,
    this.ogleScore = 0,
    this.ikindiScore = 0,
    this.aksamScore = 0,
    this.yatsiScore = 0,
    this.sabahDebt = 0,
    this.ogleDebt = 0,
    this.ikindiDebt = 0,
    this.aksamDebt = 0,
    this.yatsiDebt = 0,
  });

  UserScore copyWith({
    int? totalPoints,
    int? sabahScore,
    int? ogleScore,
    int? ikindiScore,
    int? aksamScore,
    int? yatsiScore,
    int? sabahDebt,
    int? ogleDebt,
    int? ikindiDebt,
    int? aksamDebt,
    int? yatsiDebt,
  }) {
    return UserScore(
      totalPoints: totalPoints ?? this.totalPoints,
      sabahScore: sabahScore ?? this.sabahScore,
      ogleScore: ogleScore ?? this.ogleScore,
      ikindiScore: ikindiScore ?? this.ikindiScore,
      aksamScore: aksamScore ?? this.aksamScore,
      yatsiScore: yatsiScore ?? this.yatsiScore,
      sabahDebt: sabahDebt ?? this.sabahDebt,
      ogleDebt: ogleDebt ?? this.ogleDebt,
      ikindiDebt: ikindiDebt ?? this.ikindiDebt,
      aksamDebt: aksamDebt ?? this.aksamDebt,
      yatsiDebt: yatsiDebt ?? this.yatsiDebt,
    );
  }
}
