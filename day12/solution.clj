(require '[clojure.string :as str])

(defn register-or-value
  [n]
  (let [p (if (nil? n) n (read-string n))] (if (int? p) p (keyword p))))
(defn to-instruction
  [line]
  (let
   [parts (-> line (str/trim) (str/split #" "))]
    {:opcode (case (get parts 0)
               "cpy" :cpy
               "dec" :dec
               "inc" :inc
               "jnz" :jnz
               :noop)
     :arg1 (register-or-value (get parts 1))
     :arg2 (register-or-value (get parts 2))}))

(defn cpy-instruction
  [state arg1 arg2]
  (-> state
      (update :pointer inc)
      (update :registers #(assoc % arg2 (if (int? arg1) arg1 (get % arg1))))))

(defn inc-instruction
  [state arg1 _]
  (-> state
      (update :pointer inc)
      (update :registers #(update % arg1 inc))))

(defn dec-instruction
  [state arg1 _]
  (-> state
      (update :pointer inc)
      (update :registers #(update % arg1 dec))))

(defn jnz-instruction
  [state arg1 arg2]
  (let [val (if (int? arg1) arg1 (get (get state :registers) arg1))]
    (-> state
        (update :pointer #(if (== val 0) (inc %) (+ % arg2))))))

(defn execute-instruction
  [state instruction]
  (let [arg1 (get instruction :arg1)
        arg2 (get instruction :arg2)
        opcode (get instruction :opcode)]
    ((case opcode
       :cpy cpy-instruction
       :inc inc-instruction
       :dec dec-instruction
       :jnz jnz-instruction
       (fn [s _ _] (update s :pointer inc)))
     state arg1 arg2)))

(defn execute
  [state instructions]
  (->> state
       (iterate #(execute-instruction % (get instructions (get % :pointer))))
       (drop-while #(>= (count instructions) (get % :pointer)))
       first
       (#(get-in % [:registers :a]))))

(def instructions (mapv to-instruction (line-seq (java.io.BufferedReader. *in*))))
(def initial-state {:pointer 0 :registers {:a 0 :b 0 :c 0 :d 0}})
(println (-> initial-state
             (execute instructions)))
(println (-> initial-state
             (update :registers #(assoc % :c 1))
             (execute instructions)))