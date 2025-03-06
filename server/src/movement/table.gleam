import dashboard/table.{type Dashboard}
import lib/id.{type Id}

pub fn migrations() {
  "
CREATE TABLE IF NOT EXISTS gastos.movement (
  id INT NOT NULL AUTO_INCREMENT,
  person TINYINT(1) NOT NULL,
  kind TINYINT(1) NOT NULL,
  amount INT NOT NULL,
  concept VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  installments TINYINT NOT NULL,
  dashboard_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (dashboard_id) REFERENCES gastos.dashboard
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8;
  "
}

pub type Movement {
  Movement(
    id: Id(Movement),
    person: Person,
    kind: Kind,
    amount: Int,
    concept: String,
    date: #(Int, Int, Int),
    installments: Int,
  )
}

pub type Person {
  FirstPerson
  SecondPerson
}

pub type Kind {
  /// A shared expense divided equally between the two persons
  Expense
  /// A loan that one person has to pay to the other
  Loan
}

pub fn create(
  dashboard_id: Id(Dashboard),
  person: Person,
  kind: Kind,
  amount: Int,
  concept: String,
  date: #(Int, Int, Int),
  installments: Int,
) {
  todo
}

pub fn fetch_by_date(
  from date_from: #(Int, Int, Int),
  to date_to: #(Int, Int, Int),
  in dashboard_id: Id(Dashboard),
) {
  todo
}

/// Returns movements that have installments for the next month(s).
/// The amount of these movements should be subtracted from the balance,
/// because we don't want to count these installments if they are not due yet.
/// 
/// For example if person #1 makes a $1000 expense in 10 installments, then
/// person #2 owes $50 this month, $100 next month, $150 the month after, etc.
/// Only after 10 months they owe the whole $500.
/// 
/// This function only returns the movements that have pending installments in the next month(s).
/// Movements without installments, or whose installments were all in the present/past month, are discarded.
pub fn fetch_with_due_installments(dashboard_id: Id(Dashboard)) {
  todo
}

/// Accumulates the amount of all movements.
fn fetch_balance_without_installments(dashboard_id: Id(Dashboard)) {
  todo
}

pub fn fetch_balance(dashboard_id: Id(Dashboard)) {
  todo
}
